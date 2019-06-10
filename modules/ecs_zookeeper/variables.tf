variable "name" {
  description = "アプリケーションに使用する命名。	"
  default     = "myapp"
}

variable "ecs_cluster_name" {
  description = "コンテナを配置するECSクラスタ"
  type        = "string"
}

#########################
# Container Definition
#########################
variable "number" {
  description = "Zookeeperの一意な値"
  type        = "string"
}

# variable "zoo_servers" {
#   description = ""
#   type        = "string"
# }

#########################
# Task Definition
#########################
# variable "container_definitions" {
#   description = "JSONで記述されたタスク定義"
#   type        = "string"
# }

variable "task_cpu" {
  description = "タスクのCPU"
  default     = 256
}

variable "task_memory" {
  description = "タスクのメモリ"
  default     = 512
}

variable "task_network_mode" {
  description = "タスクのネットワークモード"
  default     = "awsvpc"
}

variable "task_requires_compatibilities" {
  description = "タスクの起動タイプ e.g. 'FARGATE', 'ECS'"
  default     = "FARGATE"
}

variable "task_log_names" {
  description = "タスク定義で使用するロググループの命名 e.g. ['nginx', 'laravel', 'datadog']"
  default     = ["ecs"]
}

#########################
# Service
#########################
variable "subnets" {
  description = "コンテナを配置するサブネット"
  type        = "list"
}

variable "service_security_groups" {
  description = "コンテナへ付与するセキュリティグループ"
  type        = "list"
}

variable "service_desired_count" {
  description = "Serviceのの初回起動数"
  default     = 1
}

variable "service_discovery_namespace_id" {
  description = "ServiceDiscovery Namespace id"
  type        = "string"
}
