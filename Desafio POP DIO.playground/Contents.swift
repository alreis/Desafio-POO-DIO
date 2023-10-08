import Foundation

// Protocolo para representar uma tarefa
protocol Task {
    var title: String { get set }
    var status: TaskStatus { get set }
    
    mutating func completeTask()
}

// Enum para representar o status de uma tarefa
enum TaskStatus {
    case todo
    case inProgress
    case done
}

// Struct que conforma ao protocolo Task
struct SimpleTask: Task {
    var title: String
    var status: TaskStatus
    
    mutating func completeTask() {
        self.status = .done
    }
}

// Classe que gerencia uma lista de tarefas
class TaskManager {
    var tasks: [Task] = []
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func listTasks(withStatus status: TaskStatus) -> [Task] {
        return tasks.filter { $0.status == status }
    }
    
    func performActionOnTasks(action: (inout Task) -> Void) {
        for index in 0..<tasks.count {
            action(&tasks[index])
        }
    }
    
    func updateTaskStatusConcurrently(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        var updatedTasks: [Task] = tasks  // Crie um novo array mutável
        
        for index in 0..<updatedTasks.count {
            group.enter()
            DispatchQueue.global().async {
                sleep(UInt32.random(in: 1...3))
                updatedTasks[index].completeTask()
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.tasks = updatedTasks  // Atribua o novo array de volta à propriedade tasks
            completion()
        }
    }
}

// Criação de algumas tarefas de exemplo
var task1 = SimpleTask(title: "Fazer compras", status: .todo)
var task2 = SimpleTask(title: "Ler livro", status: .todo)
var task3 = SimpleTask(title: "Fazer exercícios", status: .inProgress)
var task4 = SimpleTask(title: "Limpar casa", status: .inProgress)

// Inicialização do gerenciador de tarefas e adição das tarefas
var taskManager = TaskManager()
taskManager.addTask(task1)
taskManager.addTask(task2)
taskManager.addTask(task3)
taskManager.addTask(task4)

// Listar tarefas em progresso
let inProgressTasks = taskManager.listTasks(withStatus: .inProgress)
print("Tarefas em progresso:")
for task in inProgressTasks {
    print(task.title)
}

// Atualizar o status das tarefas em paralelo (simulação)
taskManager.updateTaskStatusConcurrently {
    print("Status das tarefas atualizado para 'Concluído'")
    
    // Executar ação em todas as tarefas
    taskManager.performActionOnTasks { task in
        print("Ação realizada em: \(task.title)")
    }
}
