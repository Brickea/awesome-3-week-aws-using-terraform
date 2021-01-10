# Day 4 AWS CodeDeploy + Github Action + Spring Boot 自动化部署代码库最新代码<!-- omit in toc -->

👉[terraform code for part 1](terraform%20code%20for%20part%201/)
👉[springboot code for part 1](springboot%20code%20for%20part%201/)
👉[terraform code for part 2](terraform%20code%20for%20part%202/)
👉[packer code for part 2](packer%20code%20for%20part%202/)

<img src="https://media.giphy.com/media/2KAGlmkPywhZS/giphy.gif" align="right" style="width:20%">

- [Day 3 回顾](#day-3-回顾)
- [Part 1 手动实现代码部署步骤](#part-1-手动实现代码部署步骤)
  - [构建云基础设施](#构建云基础设施)
  - [书写简单的 spring boot 用来测试](#书写简单的-spring-boot-用来测试)
  - [手动上传至 EC2](#手动上传至-ec2)
  - [安装对应 java 运行环境，启动 springboot](#安装对应-java-运行环境启动-springboot)
- [Part 2 部署步骤自动化](#part-2-部署步骤自动化)
  - [使用 GitHub action 进行单元测试和打包](#使用-github-action-进行单元测试和打包)
  - [实现自动化前的思考](#实现自动化前的思考)
  - [使用 aws s3 上传代码包](#使用-aws-s3-上传代码包)
    - [使用 terraform 创建 S3 存储](#使用-terraform-创建-s3-存储)
    - [将代码部署包上传到 aws s3 中](#将代码部署包上传到-aws-s3-中)
  - [使用 aws codedeploy 部署 aws s3 中的代码包 （未完待续）](#使用-aws-codedeploy-部署-aws-s3-中的代码包-未完待续)
- [AWS Codedeploy](#aws-codedeploy)
- [AWS S3](#aws-s3)



## Day 3 回顾

在 Day 3 中，我们使用 Packer 创建了自定义虚拟机镜像，其中包含了我们指定安装的程序环境(Java jdk)。然后我们第一次认识了 Github action，并为其编写了 push 所触发的工作流，最终实现了 “推送最新 ami 代码即可触发 packer 的虚拟机镜像创建” 过程。

在 Day 4 中，我们来认识一下 AWS codedeploy 和 AWS S3 存储。最终通过这两个服务实现以下效果：“每当代码推送到 GitHub 上，指定的云虚拟机就会自动部署最新代码”

这一次中我们使用 spring boot 和 maven

回顾上文我们提到的最终效果 “每当代码推送到 GitHub 上，指定的云虚拟机就会自动部署最新代码”，直觉上我们需要做以下的步骤：
* 创建云基础设施
* 书写 spring boot 相关代码
* 将 spring boot 代码推送到 github 上
* 出发 GitHub action 执行一下步骤：
  * 单元测试
  * 打包 spring boot 代码成为 jar 包 (这样做是因为 jar 包可以通过命令 ```java -jar nameOfJar.jar``` 来启动)
  * 将 jar 包上传至指定云虚拟机
  * 在云虚拟机中启动对应 jar 包

在 part 1 中，我们将学习如何手动实现上述代码部署步骤

在 part 2 中，我们将学习如何将上述代码部署步骤自动化

## Part 1 手动实现代码部署步骤

---

### 构建云基础设施

首先我们沿用 Day 2 中构建的云基础设施，创建对应的 EC2、 VPC、 Security Group、 subnet、 Internet Gateway、 route

其中 Security Group 要注意开放 80、22 端口

### 书写简单的 spring boot 用来测试

使用 springboot initializater 创建 springboot 项目

在对应 pom 文件下添加以下依赖

```xml
  <dependencies>
      <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-web</artifactId>
      </dependency>

      <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-test</artifactId>
          <scope>test</scope>
      </dependency>

      <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-thymeleaf</artifactId>
      </dependency>
  </dependencies>
```

之后创建 controller ```hello.java```

```java
package brickea.awesomeDay4Part1.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HelloController {
    @GetMapping("/hello")
    public String hello(){
        return "hello";
    }
}

```

在 ```resource``` 下 创建 ```templates``` 目录，并在其中创建对应要渲染的 ```hello.html```

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">

</head>
<body>

    <h1>Awesome !!!</h1>

</body>
</html>
```

在这之后，我们通过使用  maven 进行打包

> 注：如果此时没有安装 maven 需要进行安装 ```sudo apt-get update``` 之后 ``` sudo apt-get install maven```

如果有 maven

在 pom.xml 根目录下执行打包

```sudo mvn package```

![](res/mvn%20package.png)

最后会在 ```target``` 目录下生成对应的 ```jar``` 包

![](res/jar%20package.png)

### 手动上传至 EC2 

使用 scp 命令

```scp -i pem密钥 jar包 ubuntu@ip:~```

![](res/remote%20ajr.png)

> 此时已经上传至 EC2 上了

### 安装对应 java 运行环境，启动 springboot

```sudo apt-get update```

```sudo apt-get install default-jdk```

```java -jar jar包```

![](res/springboot%20start.png)

此时我们在浏览器访问 ```ec2ip/hello```

就可以看到我们的 awesome 字样了

![](res/browser%20visit.png)

接下来，我们将学习如何将上述 “单测、打包、上传、启动” 过程自动化

## Part 2 部署步骤自动化

---

### 使用 GitHub action 进行单元测试和打包

我们将会创建 awesome_webapp 代码仓库

在 awesome_webapp 代码仓库的 根目录下创建 ```.github/workflows``` 目录，并在此目录中创建 ```codedeploy.yml``` 文件

之后将我们在 part 1 中创建的 springboot 项目整个放入到这个代码仓库中，修改 springboot 项目文件名为 ```springbootCode```

并在 springboot 项目文件夹 ```springbootCode``` 下的 ```.gitignore``` 内容覆盖为如下内容：

```gitignore
HELP.md
target/
!.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

### IntelliJ IDEA ###
.idea
*.iws
*.iml
*.ipr

### NetBeans ###
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/
build/
!**/src/main/**/build/
!**/src/test/**/build/

### VS Code ###
.vscode/

# Compiled class file
*.class

# Log file
*.log

# BlueJ files
*.ctxt

# Mobile Tools for Java (J2ME)
.mtj.tmp/

# Package Files #
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# virtual machine crash logs, see http://www.java.com/en/download/help/error_hotspot.xml
hs_err_pid*

target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
# https://github.com/takari/maven-wrapper#usage-without-binary-jar
.mvn/wrapper/maven-wrapper.jar

```

这样我们就不会将工程生成的文件添加到代码库追踪记录中

此时文件目录应如下：

![](res/codedeployFilePath.png)

在 ```codedeploy.yml``` 文件中写入以下内容

```yml

# This workflow will build a Java project with Maven
# For more information see: https://help.github.com/actions/language-and-framework-guides/building-and-testing-java-with-maven

name: Build & Deploy WebApp

env: # 这里定义了一些变量名
  ARTIFACT_NAME: awesome-webapp-${{ github.sha }}.zip # 这里用到的 github.sha 会生成一个随机字符串，用来区分每一次构建的代码包

on: # action 出发条件为 master 分支的 push 操作
  push:
    branches:
      - master

jobs:
  ci_cd:

    runs-on: ubuntu-latest # 这里指定了github action 的执行环境

    steps:
    - uses: actions/checkout@v2 # 在 github action 的执行环境中拉取 本仓库最新代码

    - name: Set up JDK 11 # 安装最新 jdk
      uses: actions/setup-java@v1
      with:
        java-version: '11'
    
    - name: Build with Maven # 使用 maven 进行单元测试和 jar 包打包
      run: | # run 后面写的内容，每一行可以理解为在 GitHub action 环境中按照顺序执行的每一行命令 这些命令的执行结果可以在 GitHub action 上看到
        echo '当前 java 版本'
        java -version

        echo '代码包包名：${{env.ARTIFACT_NAME}}'

        echo '当前路径为代码仓库的根目录'
        pwd
        ls

        echo '使用 maven 进行依赖安装并且进行单元测试和 jar 包打包'
        sudo mvn -B clean install --file springbootCode/pom.xml
        sudo mvn -e -B package --file springbootCode/pom.xml
        echo '完成依赖安装以及单元测试和 jar 包打包'

        pwd
        echo '查看 target 文件目录下是否有 jar 包'
        ls -al springbootCode/target

        echo '移动到 target 文件目录下'
        cd springbootCode/target
        pwd
        ls -al

```

之后我们 add 并 push 此代码

调整到 GitHub action 的显示页面，我们可以看到如下内容被执行

![](res/codedeployMaven.png)
> 此时执行了我们预先写在 yml 中的命令

![](res/codedeployUnitTest.png)
> 在执行 maven 打包过程中会自动运行 springboot 中写好的 unit test，这里我就只是简单写了两行输出 start 和 over

![](res/codedeployCd.png)
> 最终我们检查一下 GitHub action 运行环境中是否真正在 target 目录下生成了对应的 jar 包，确实已经生成了

到此，我们使用 GitHub action 进行 maven 单测和打包就算是完成了，接下来我们将实现代码包部署并启动的自动化操作

### 实现自动化前的思考

让我们回忆刚刚 part 1 中手动部署代码包和启动的操作

我们首先使用 scp 命令将生成的 jar 包上传到指定的 ec2 中，之后我们再 ssh 登录到对应的 ec2 中，通过 ```java -jar jar包``` 的方式将我们的 spring boot 应用启动

接下来，让我们思考如何通过 GitHub action 来实现上述“上传”的步骤

直觉上来说，我们可以在 GitHub action 中通过 scp 将上一步 “使用 GitHub action 进行单元测试和打包” 中 target 文件夹中生成的 jar 包上传到指定 ec2

但是这样会产生一些问题

* 使用 scp 必须要知道对应 ec2 的 ip
* scp 会使用 pem 密钥文件

pem 文件可以通过 github secret 的方式解决，ip 可以每次出发 GitHub action 前去确认 对应 ip 传输给 GitHub action

但是如我们真的这样做的话，就意味着每次出发 GitHub action 都要手动配置 ip

这样有点脱裤子放屁的感觉，不够自动化

所以接下来我们要使用 aws s3 和 aws codedeploy 这两个服务来实现真正的 “推送代码即测试+部署” 这一操作

**aws s3 一句话带过**就是一个存储服务，你可以把各种东西放到上面，然后他会提供一个外部下载访问的链接

**aws codedeploy 一句话带过**就是代码部署服务，你可以通过配置指定它在那些资源上进行诸如 代码上传，脚本执行等操作

在本次教程中，我们的流程如下

* 本地编辑 springboot 代码
* 通过 git push 到 GitHub 上并出发 GitHub action
* 通过 GitHub action 进行代码单元测试和打包
* 通过 GitHub action 将代码包上传至 s3 存储
* 通过 GitHub action 使用 codedeploy 将 s3 存储中上传的代码部署包部署到指定 ec2 上

### 使用 aws s3 上传代码包

修改 awesome_webapp 中的 GitHub action 工作流如下：

```yml
# This workflow will build a Java project with Maven
# For more information see: https://help.github.com/actions/language-and-framework-guides/building-and-testing-java-with-maven

name: Build & Deploy WebApp

env: # 这里定义了一些变量名
  ARTIFACT_NAME: awesome-webapp-${{ github.sha }}.zip # 这里用到的 github.sha 会生成一个随机字符串，用来区分每一次构建的代码包，防止重名

on: # action 出发条件为 master 分支的 push 操作
  push:
    branches:
      - main

jobs:
  ci_cd:

    runs-on: ubuntu-latest # 这里指定了github action 的执行环境

    steps:
    - uses: actions/checkout@v2 # 在 github action 的执行环境中拉取 本仓库最新代码

    - name: Set up JDK 11 # 安装最新 jdk
      uses: actions/setup-java@v1
      with:
        java-version: '11'
    
    - name: Build with Maven # 使用 maven 进行单元测试和 jar 包打包
      run: | # run 后面写的内容，每一行可以理解为在 GitHub action 环境中按照顺序执行的每一行命令 这些命令的执行结果可以在 GitHub action 上看到
        echo '当前 java 版本'
        java -version

        echo '代码包包名：${{env.ARTIFACT_NAME}}'

        echo '当前路径为代码仓库的根目录'
        pwd
        ls

        echo '使用 maven 进行依赖安装并且进行单元测试和 jar 包打包'
        sudo mvn -B clean install --file springbootCode/pom.xml
        sudo mvn -e -B package --file springbootCode/pom.xml
        echo '完成依赖安装以及单元测试和 jar 包打包'

        pwd
        echo '查看 target 文件目录下是否有 jar 包'
        ls -al springbootCode/target

        echo '移动到 target 文件目录下'
        cd springbootCode/target
        pwd
        ls -al

# ---------以下为新添加的内容------------------
    - name: Build Deployment Artifact # 创建上传到 s3 中的 代码部署包
      run: |
        echo '创建 codedeploy_artifact 目录'
        mkdir codedeploy_artifact
        echo '将对应 jar 包压缩'
        zip -r ${{ env.ARTIFACT_NAME }} springbootCode/target/awesomeday4part1-0.0.1-SNAPSHOT.jar
        ls -al
        echo '将对应压缩包 zip 放入到 codedeploy_artifact 目录'
        mv ${{ env.ARTIFACT_NAME }} codedeploy_artifact/
        ls -al
        echo '进入 codedeploy_artifact 目录进行验证'
        cd codedeploy_artifact
        ls -al

    - name: Configure AWS credentials # 配置 aws cli，指定将要操作的账号
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWSACCESSKEYID }}
        aws-secret-access-key: ${{secrets.AWSSECRETKEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Copy Artifact to S3 # 将对应 zip 压缩文件上传到 s3 存储中
      run: | # 此时我们并没有创建 s3 存储！！！
        aws s3 sync ./codedeploy_artifact s3://${{ secrets.S3_CODEDEPLOY_BUCKET }}

```

这时候你会发现这里有一个全新的 github secrets 变量 ```S3_CODEDEPLOY_BUCKET```，此时我们并没有创建 s3 存储

接下来我们对我们的 terraform 文件进行修改

#### 使用 terraform 创建 S3 存储

创建 ```8_s3.tf``` 文件并输入以下配置

```go

// 创建 用来进行代码部署的 S3---------------------------------------------
resource "aws_s3_bucket" "awesome_webapp_s3" {
  bucket = "codedeploy.awesome.me" // 这里的命名是有要求的，如果我们将来打算使用的 domain name 是 awesome.me 那么命名必须遵循 bucketName.awesome.me
  acl    = "private"

  force_destroy = true // 无论此 s3 存储是否有内容存入，都允许 terraform 执行 destroy
  // 如果不写这个配置，会导致每一次 apply 之后必须手动清空 s3 之后才能正常执行 terraform destroy

  // 启用加密，对我们使用没有直接影响，只是让这个 s3 存储更安全
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = {
    Name        = "awesome webapp codedeploy s3"
  }
}
```

之后让我们 terraform apply 一下

再登录 aws 网页就能看到我们创建的 s3 bucket 了

![](res/s3Bucket.png)

#### 将代码部署包上传到 aws s3 中

继本节中创建的 yml

```yml
# This workflow will build a Java project with Maven
# For more information see: https://help.github.com/actions/language-and-framework-guides/building-and-testing-java-with-maven

name: Build & Deploy WebApp

env: # 这里定义了一些变量名
  ARTIFACT_NAME: awesome-webapp-${{ github.sha }}.zip # 这里用到的 github.sha 会生成一个随机字符串，用来区分每一次构建的代码包

on: # action 出发条件为 master 分支的 push 操作
  push:
    branches:
      - main

jobs:
  ci_cd:

    runs-on: ubuntu-latest # 这里指定了github action 的执行环境

    steps:
    - uses: actions/checkout@v2 # 在 github action 的执行环境中拉取 本仓库最新代码

    - name: Set up JDK 11 # 安装最新 jdk
      uses: actions/setup-java@v1
      with:
        java-version: '11'
    
    - name: Build with Maven # 使用 maven 进行单元测试和 jar 包打包
      run: | # run 后面写的内容，每一行可以理解为在 GitHub action 环境中按照顺序执行的每一行命令 这些命令的执行结果可以在 GitHub action 上看到
        echo '当前 java 版本'
        java -version

        echo '代码包包名：${{env.ARTIFACT_NAME}}'

        echo '当前路径为代码仓库的根目录'
        pwd
        ls

        echo '使用 maven 进行依赖安装并且进行单元测试和 jar 包打包'
        sudo mvn -B clean install --file springbootCode/pom.xml
        sudo mvn -e -B package --file springbootCode/pom.xml
        echo '完成依赖安装以及单元测试和 jar 包打包'

        pwd
        echo '查看 target 文件目录下是否有 jar 包'
        ls -al springbootCode/target

        echo '移动到 target 文件目录下'
        cd springbootCode/target
        pwd
        ls -al

# ---------以下为新添加的内容------------------
    - name: Build Deployment Artifact # 创建上传到 s3 中的 代码部署包
      run: |
        echo '创建 codedeploy_artifact 目录'
        mkdir codedeploy_artifact
        echo '将对应 jar 包压缩'
        zip -r ${{ env.ARTIFACT_NAME }} springbootCode/target/awesomeday4part1-0.0.1-SNAPSHOT.jar
        ls -al
        echo '将对应压缩包 zip 放入到 codedeploy_artifact 目录'
        mv ${{ env.ARTIFACT_NAME }} codedeploy_artifact/
        ls -al
        echo '进入 codedeploy_artifact 目录进行验证'
        cd codedeploy_artifact
        ls -al

    - name: Configure AWS credentials # 配置 aws cli，指定将要操作的账号
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWSACCESSKEYID }}
        aws-secret-access-key: ${{secrets.AWSSECRETKEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Copy Artifact to S3 # 将对应 zip 压缩文件上传到 s3 存储中
      run: | # 此时我们并没有创建 s3 存储！！！
        aws s3 sync ./codedeploy_artifact s3://${{ secrets.S3_CODEDEPLOY_BUCKET }}
```

让我们试一下能否真正上传到对应的 s3 存储中

使用 git push 到代码仓库的 main 分支中

查看 GitHub action 的执行状况

![](res/uploadS3GithubAction.png)

查看 s3 里面是不是有了对应的 zip 文件

![](res/s3Status.png)

> 我们可以发现 zip 文件已经上传到对应的 s3 bucket 里面了

### 使用 aws codedeploy 部署 aws s3 中的代码包 （未完待续）

对于使用 codedeploy 你可以查看 AWS 的[官方文档](https://docs.aws.amazon.com/zh_cn/codedeploy/latest/userguide/tutorials-windows-deploy-application.html) 来获取更详细的信息

这里我进行简单的概括

想要借助 aws codedeploy 来部署位于 s3 存储中的代码包，我们必须保证

* 部署目的地资源已安装 codedeploy 代理
* 创建对应的部署组。不过，在创建部署组之前，我们需要服务角色 ARN。服务角色是 IAM 角色，该角色授予某个服务代表您执行操作的权限。在这种情况下，服务角色将为 CodeDeploy 提供访问我们的 Amazon EC2 实例的权限，以扩展（读取）其 Amazon EC2 实例标签。

首先我们来处理第一个要求 “部署目的地资源已安装 codedeploy 代理”

还记得我们使用 packer 来创建对应环境的虚拟机镜像吗

在这里我们将通过编辑 packer 来创建一个虚拟机镜像，其中包含以下环境

* java jdk
* codedeploy 代理

接下来，我们修改之前的 packer 代码

将 shell-script 中的 base.sh 更改为以下内容

```sh
# wait for 
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

sudo apt-get update -y

# install java jdk
sudo apt-get install -y default-jdk

echo "*********************intalling CodeDeploy*********************"
sudo apt-get install ruby -y
# cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ~/install
sudo ./install auto

# 这样就能保证以这个镜像为蓝本的 ec2 会直接启动 codedeploy 代理
sudo service codedeploy-agent start 
sudo service codedeploy-agent status
echo "*********************install CodeDeploy finish*********************"
```

修改 bash.sh 后，git push 触发 GitHub action 来生成对应虚拟机镜像

然后修改我们 terraform 中 ec2 使用的 ami 镜像为上一步骤中生成的 ami id

接下来，我们来解决第二个要求，也就是

创建对应的部署组。不过，在创建部署组之前，我们需要服务角色 ARN。服务角色是 IAM 角色，该角色授予某个服务代表您执行操作的权限。在这种情况下，服务角色将为 CodeDeploy 提供访问我们的 Amazon EC2 实例的权限，以扩展（读取）其 Amazon EC2 实例标签。

这个是可以通过 terraform 完成配置的

会到之前我们 terraform 工作目录下，创建文件 ```9_codedeploy.tf```并输入以下内容

```go
// 创建部署应用 CodeDeploy Application
resource "aws_codedeploy_app" "webapp_codeDeploy_app" {
  compute_platform = "Server"
  name             = "awesome-webapp"
}

// 创建部署组 CodeDeploy Application Group
resource "aws_codedeploy_deployment_group" "webapp_CD_group" {
  app_name              = aws_codedeploy_app.webapp_codeDeploy_app.name // 使用前面创建的部署应用
  deployment_group_name = "awesome-webapp-deployment"
  service_role_arn      = aws_iam_role.codeDeployService_access_role.arn // 关于这个后文会解释

  deployment_style {
    deployment_type   = "IN_PLACE" // in place 的部署方式就是在哪部署代码，就在哪执行各种操作
  }

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    // 部署失败的时候回滚
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  // 通过 tag 寻找要部署的 ec2
   ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "my-first-ec2-instance"
    }
  }

  depends_on = [aws_codedeploy_app.webapp_codeDeploy_app]
}
```

接下来我们创建为 CodeDeploy 提供访问 Amazon EC2 实例的权限的 role

## AWS Codedeploy

<!-- TODO -->codedeploy 介绍

<!-- TODO -->使用 aws cli 进行 codedeploy，本地上传部署包

## AWS S3

<!-- TODO -->S3 介绍

<!-- TODO -->结合 S3 本地上传部署包，使用 aws cli 进行 codedeploy

<!-- TODO -->使用 GitHub action 推送代码即可进行代码单元测试、代码打包、上传打包到 S3、执行 codedeploy