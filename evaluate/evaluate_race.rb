require "csv"

@dir_name = ARGV[0] 
@direction = ARGV[1] #left or right

def is_direction(direction, racecourse)
  if direction == "left"
    racecourse.include?("中京") || racecourse.include?("東京") || racecourse.include?("新潟")
  else
    !(racecourse.include?("中京") || racecourse.include?("東京") || racecourse.include?("新潟"))
  end
end

def eval_race
  this_year = CSV.table("datas/#{@dir_name}/this_year.csv", encoding: "UTF-8")
  result = {}
  this_year.each do |data|
    result.store(data[:horsename],[])
  end
  this_year.each do |data|
    if is_direction(@direction, data[:racecourse])
      result[data[:horsename]].push(data[:timepoint])
    end
  end
  
  csv_data = []
  result.each do |res|
    horse_name = res[0]
    t = res[1].map{|x|x.to_f}
    num = t.size
    num = 5 if t.size > 5
    num = 1 if t.size == 0
    time_point_ave = t.take(5).sum / num
    csv_data.push([horse_name, time_point_ave.round(2)])
  end
  sorted = csv_data.sort_by{|x| x[1]*-1 }
  sorted = round_five(sorted)
  sorted.unshift(["horseName","timepoint","round"])
  write(sorted, "evaluated_racepoint")
end

def round_five(result)
  time_points = []
  result.each do |res|
    time_points.push res[1].to_f
  end
  ave = time_points.sum / time_points.size
  time_points.each_with_index do |t,i|
    if t==0
      time_points[i] = ave
    end
  end
  min = time_points.min - 10
  time_points = time_points.map{|x|(x-min)}
  max = time_points.max

  div_num = max.to_f / 5

  five_rounds = time_points.map{|x|(x / div_num).round(2)}
  
  result.each_with_index do |res, i|
    res.push(five_rounds[i])
  end
  result
end

def write(csv_data, file_name)
  CSV.open("datas/#{@dir_name}/#{file_name}.csv", "w") do |csv| 
    csv_data.each do |data|
      csv << data
    end
  end
end

eval_race()


