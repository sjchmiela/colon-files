# Model
class ColonBase < ActiveRecord::Base
  @@config = YAML.load_file(File.join(__dir__, 'config.yml'))
  self.abstract_class = true
end

class Solution < ColonBase
  def self.path(solution_id)
    File.join(@@config["solutions"]["path"], solution_id.to_s)
  end
end

class Task < ColonBase
  def self.inPath(task_id)
    File.join(@@config["tasks"]["path"], task_id.to_s + ".in")
  end
  def self.outPath(task_id)
    File.join(@@config["tasks"]["path"], task_id.to_s + ".out")
  end
end
