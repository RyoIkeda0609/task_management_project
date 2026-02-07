
enum TaskStatus {
  todo,
  doing,
  done;

  int get progress {
    switch (this) {
      case TaskStatus.todo:
        return 0;
      case TaskStatus.doing:
        return 50;
      case TaskStatus.done:
        return 100;
    }
  }
}
