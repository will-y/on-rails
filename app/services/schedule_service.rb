require 'cassandra'

class ScheduleService

  @canOrderBy = %w[arrivingAt time train goingTo]

  def initialize
    @cluster = Cassandra.cluster(hosts: %w[137.112.104.137 137.112.104.136 137.112.104.138])
    @stations = @cluster.connect("stations")
  end

  def addToSchedule(arrivingAt, time, goingTo, train, price)
    seeIfExists = @stations.prepare('SELECT * From arrivals Where arrivingAt = ? and time = ? and train = ? ALLOW FILTERING;')
    addTrainTime = @stations.prepare('INSERT INTO arrivals (arrivingAt, time, goingTo, train, price) VALUES (?,?,?,?,?)')

    duplicates = @stations.execute(seeIfExists, arguments: [arrivingAt, time, train])
    if not duplicates.empty?
      return "This station, time, and train combination already exists";
    else
      @stations.execute(addTrainTime, arguments: [arrivingAt, time, goingTo, train, price])
      return ""
    end
  end

  def editSchedule (oldArrivingAt, oldTime, oldTrain, newArrivingAt, newTime, newTrain, newGoingTo, newPrice)
    seeIfExists = @stations.prepare('SELECT * From arrivals Where arrivingAt = ? and time = ? and train = ? LIMIT 1 ALLOW FILTERING;')

    exists = @stations.execute(seeIfExists, arguments: [oldArrivingAt, oldTime, oldTrain])
    if not exists.empty?
      removeFromSchedule(oldArrivingAt,oldTime,oldTrain)
      addToSchedule(newArrivingAt,newTime,newGoingTo,newTrain,newPrice)
      return ""
    else
      return "This station, time, and train combination does not exist";
    end
  end

  def removeFromSchedule(arrivingAt, time, train)
    seeIfExists = @stations.prepare('SELECT * From arrivals Where arrivingAt = ? and time = ? and train = ? LIMIT 1 ALLOW FILTERING;')
    removeTrainTime = @stations.prepare('Delete From arrivals Where arrivingAt = ? and time = ? and train = ?')

    exists = @stations.execute(seeIfExists, arguments: [arrivingAt, time, train])
    if not exists.empty?
      @stations.execute(removeTrainTime, arguments: [arrivingAt, time, train])
      return ""
    else
      return "This station, time, and train combination does not exist";
    end
  end

  def getSchedule
    search = @stations.prepare("Select * From arrivals")
    results = @stations.execute(search)
    return results
  end

  def get_row(arrivingAt, time, train)
    search = @stations.prepare("Select * From arrivals Where arrivingAt = ? and time = ? and train = ? ALLOW FILTERING;")
    results = @stations.execute(search, arguments: [arrivingAt, time, train])
    return results;
  end


  def filter (arrivingAt, time, train, goingTo)
    query = "Select * From arrivals"
    isFirstElement = true;

    if arrivingAt != ''
      if isFirstElement
        query = query + " Where arrivingAt = '" + arrivingAt + "'"
        isFirstElement = false;
      else
        query = query + " and arrivingAt = '" + arrivingAt + "'"
      end
    end

    if time != ''
      if isFirstElement
        query = query + " Where time = '" + time + "'"
        isFirstElement = false;
      else
        query = query + " and time = '" + time + "'"
      end
    end

    if train != ''
      if isFirstElement
        query = query + " Where train = '" + train + "'"
        isFirstElement = false;
      else
        query = query + " and train = '" + train + "'"
      end
    end

    if goingTo != ''
      if isFirstElement
        query = query + " Where goingTo = '" + goingTo + "'"
        isFirstElement = false;
      else
        query = query + " and goingTo = '" + goingTo + "'"
      end
    end

    search = @stations.prepare(query + " allow filtering;")
    results = @stations.execute(search)

    return results

  end

end
