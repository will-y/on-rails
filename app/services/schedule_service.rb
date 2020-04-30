require 'cassandra'

class ScheduleService

  @canOrderBy = %w[arrivingAt time train goingTo]

  def initialize
    @cluster = Cassandra.cluster(hosts: ['137.112.104.137', '137.112.104.136', '137.112.104.138'])
    @stations = @cluster.connect("stations")
  end

  def addToSchedule(arrivingAt, time, goingTo, train)
    seeIfExists = @stations.prepare('SELECT * From arrivals Where arrivingAt = ? and time = ? and train = ? ALLOW FILTERING;')
    addTrainTime = @stations.prepare('INSERT INTO arrivals (arrivingAt, time, goingTo, train) VALUES (?,?,?,?)')

    duplicates = @stations.execute(seeIfExists, arguments: [arrivingAt, time, train])
    puts(duplicates.empty?)
    if not duplicates.empty?
      return "This station, time, and train combination already exists";
    else
      @stations.execute(addTrainTime, arguments: [arrivingAt, time, goingTo, train])
      return ""
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
    #TODO: Give the single record that matches this key
    {arrivingat: "ex", "time": "ex", train: "train", goingto: "ex", price: 12, price_1st:20}.with_indifferent_access
  end


end