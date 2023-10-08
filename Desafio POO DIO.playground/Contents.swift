import Foundation

// Enum para representar o status de uma tarefa
enum TaskStatus {
    case todo
    case inProgress
    case done
}

// Struct para representar uma tarefa
struct Task {
    var title: String
    var status: TaskStatus
}

// Classe que gerencia a lista de tarefas
class TaskManager {
    var tasks: [Task] = []
    
    // Função para adicionar uma tarefa à lista
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    // Função para listar tarefas com base no status
    func listTasks(withStatus status: TaskStatus) -> [Task] {
        return tasks.filter { $0.status == status }
    }
    
    // Função que usa uma closure para executar uma ação em todas as tarefas
    func performActionOnTasks(action: (inout Task) -> Void) {
        for index in 0..<tasks.count {
            action(&tasks[index])
        }
    }
    
    // Função que demonstra concorrência usando DispatchGroup
    func updateTaskStatusConcurrently(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for index in 0..<tasks.count {
            group.enter()
            DispatchQueue.global().async {
                // Simulando um processo assíncrono, como uma chamada de rede
                sleep(UInt32.random(in: 1...3))
                self.tasks[index].status = .done
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}

// Criação de algumas tarefas de exemplo
var task1 = Task(title: "Fazer compras", status: .todo)
var task2 = Task(title: "Ler livro", status: .todo)
var task3 = Task(title: "Fazer exercícios", status: .inProgress)
var task4 = Task(title: "Limpar casa", status: .inProgress)

// Inicialização do gerenciador de tarefas e adição das tarefas
let taskManager = TaskManager()
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

