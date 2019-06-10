ecs-zookeeper
---

# 概要
ECSでZookeeperを起動するサンプル  

現状、Fargateで起動し、バックアップが行えないことが課題。  
EC2クラスターとEBS（もしくはEFS）を使用することで解決可能。

## Components
- VPC
- CloudMap (Service Discovery)
    - Namespace
    - Service
- ECS Cluster
- ECS TaskDefinition
- ECS Service

# How To Use
## Versions
```
$ terraform version
Terraform v0.12.1
+ provider.aws v2.14.0
+ provider.template v2.1.2
```

## initialize 
```
$ terraform init
$ terraform workspace new stg
$ terraform workspace select stg
```

## Provisioning
```
$ terraform apply
```

# todo
- [ ] ECSのEC2クラスターを構築
- [ ] 既存のタスク定義をEC2へ対応
- [ ] EC2とEBS（もしくはEFS）のヒモ付け
- [ ] ECSで起動したZookeeperの `/data` 配下をEBS（もしくはEFS）と紐付け
- [ ] Zookeeperのヘルスチェック
- [ ] Datadogとの連携

# memo
- FargateはEBSもしくはEFSをマウントできないため、データの永続化（またはバックアップ）が不可能
    - そのため、プロダクションではタスクが全台落ちるとデータが完全にロストするため、Fargateの使用は2019年6月時点では使用不要
    - ロードマップにはFargateへEFSをマウントするチケットが存在
