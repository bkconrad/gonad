require "./knowledge"

# defines and tracks the various tasks and decisions necessary to progress
# satisfactorily. all decision-making logic goes here, and this will be the
# class to inherit from when creating custom AIs
module AI
  @@tasks = []
  @@parameters = []
  
  # check current task's status, remove it if it's completed and return the
  # steps to complete the new (or old) task
  def perform_next_task
    if next_task.complete?
      dbg ("completed task #{next_task}")
      @@tasks.pop
      dbg ("now performing task #{next_task}")
    end
    return next_task.perform
  end

  def next_task
    return @@tasks.last
  end

  def add_task task
    dbg ("adding task #{task}")
    @@tasks.push(task)
  end
end
