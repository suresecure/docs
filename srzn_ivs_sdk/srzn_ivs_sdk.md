---
title: 智能分析接口说明
author: 湖南戍融智能科技有限公司xcq
date: 20170227
institute: 戍融智能 
toc-title: content

---

#设备、服务间报警传递接口
##接口服务功能说明
设备向管理服务程序，与服务程序向第三方传递报警使用的是相同的接口，接口基于
[GRPC](http://www.grpc.io/)设计，接口描述在附带的proto文件中，该接口主要涉及
到一个服务中的两个rpc调用，定义如下：

```
service SurvCenterService{
  rpc ReportEvent (Event) returns (GeneralReply) {}
  rpc Heartbeat(HeartbeatRequest) returns (GeneralReply) {}
}
```
服务名字为SurvCenterService，ReportEvent和Heartbeat分别为提交报警和心跳的调用。
当设备向管理服务程序提交报警时，设备为客户端，管理服务器程序服务端。
当管理服务程序向第三方提交报警时，管理服务器程序客户端，第三饭为服务端。

##接口数据结构说明
###通用返回信息
```
message GeneralReply{
  int32 error_code = 1;
  string message = 2;
}
```
提交报警和心跳的返回数据相同，都是GeneralReply，目前该数据的两个成员都未使用
状态，只要能够返回就表明操作成功。

###报警数据内容
报警数据结构如下，每个域的含义见注释：
```
message Event {
  //报警唯一id
  string guid = 1;
  //报警类型
  int32 type = 2;
  //报警时间，从1970年1月1日0时至今的秒数
  int64 seconds = 3;
  //描述信息
  string description = 4;
  //报警主机ip地址
  string hostaddress = 5;
  //报警信息所属通道号
  int32 channel = 6;
  //保留
  string video_filename = 7;
  //前段设备固件版本号
  string frontend_version = 8;

  //带标志报警图片序列
  repeated AnnotatedImage anno_imgs = 9;
  //保留
  int32 person_num = 10;
  //保留
  int32 meter_area_num = 11;
  //报警设备id
  string device_ident = 12;
}
```
<!--其中报警类型说明如下：-->

其中需要详细说明的是带标志报警图片序列，该图片序列可能为1张，
也可能为多张。每张图片的数据结构如下：
```
message Target{
  //目标在图像中x，y坐标和宽高w，h
  int32 x = 1;
  int32 y = 2;
  int32 w = 3;
  int32 h = 4;
  //保留
  Type type = 5;
  //保留
  Status status = 6;
}

message AnnotatedImage{
  //jpeg压缩图片二进制数据
  bytes img = 1;
  //保留
  string comment = 2;
  //报警图片中出发报警的目标
  //目前仅在异常人脸报警中有效
  //表示异常人脸位置
  repeated Target targets = 3;
  //保留
  repeated SettingArea setting_areas = 4;
}
```

###心跳数据内容
心跳信息由设备ip地址和设备id构成，由于考虑设备在NAT路由器背后，
导致ip地址不唯一，所以增加设备id，通常在内网时使用ip地址即可。
```
message HeartbeatRequest{
  //发送报警信息设备ip地址
  string device_address = 1;
  //发送报警信息设备id
  string device_ident = 2;
}
```

##Csharp调用示例
附件内包含了模拟报警信息发送程序和模拟报警信息接收程序的源码供参考，
###环境需求
* .NET Framework 4.5+
* Visual Studio 2013 or 2015. DEMO程序为VS2013编译

###使用NUGET安装依赖包
```
  <package id="Google.Protobuf" version="3.2.0" targetFramework="net45" />
  <package id="Grpc" version="1.1.0" targetFramework="net45" />
  <package id="Grpc.Core" version="1.1.0" targetFramework="net45" />
  <package id="System.Interactive.Async" version="3.1.1" targetFramework="net45" />
```
如果NUGET版本不够请升级，在升级以后如果遇到如下错误：
vs2013未找到与约束匹配的导出
解决方法：

- 关闭VS；
- 去```C:/Users/<your users name>/AppData/Local/Microsoft/VisualStudio/12.0/ComponentModelCache```文件夹下删除所有文件及文件夹；
- 重新打开VS即可。

在提供的DEMO项目中已经包含了依赖包说明，只需要打开SLN文件，
通常会自动下载依赖包，否则可以点击```项目->启用NuGet程序包还原```。

###程序编译
请首先执行DEMO目录下的generate_protos.bat文件来生成C#代理类。
SLN中共包含3个项目，srzn-ivs-sdk、ivs-event-client、ivs-event-server，
分别包含代理类、模拟客户端、模拟服务端。
GRPC代理类包含两个文件Suresecureivs.cs和SuresecureivsGrpc.cs，分别封装proto文件的message和rpc。

###示例客户端
```cs
using System;
using Grpc.Core;
using Suresecureivs;

namespace ivs_event_client
{
    class Program
    {
        public static void Main(string[] args)
        {
            //建立通道
            Channel channel = new Channel("127.0.0.1:50051", ChannelCredentials.Insecure);

            //新建客户端
            var client = new SurvCenterService.SurvCenterServiceClient(channel);
            //任意设置一些属性值
            String user = "you";
            //新建报警事件
            Event nevent = new Event();
            nevent.Description = user;
            //新建报警事件图片
            AnnotatedImage anno_img = new AnnotatedImage();
            //将二进制JPEG码流拷贝到报警事件图片中
            anno_img.Img = Google.Protobuf.ByteString.CopyFrom(new byte[] { 1, 2 });
            //设置报警事件图片中的目标
            Target target = new Target { X = 1, Y = 2, W = 3, H = 4, Type = Target.Types.Type.Person };
            anno_img.Targets.Add(target);
            nevent.AnnoImgs.Add(anno_img);

            //向服务器提交报警事件
            var reply = client.ReportEvent(nevent);
            Console.WriteLine("Greeting: " + reply.Message);

            channel.ShutdownAsync().Wait();
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
}
```

###示例服务端
```cs
using System;
using System.Threading.Tasks;
using Grpc.Core;
using Suresecureivs;

namespace ivs_event_server
{
    //实现接收报警服务
    class EventReporttingImpl : EventReporting.EventReportingBase
    {
        // Server side handler of the SayHello RPC
        public override Task<ReportEventReply> ReportEvent(Event request, ServerCallContext context)
        {
            //接收到报警以后简单回复
            Console.WriteLine(request.AnnoImgs);
            return Task.FromResult(new ReportEventReply { Message = "Hello " + request.Description });
        }
    }

    class Program
    {
        const int Port = 50051;

        public static void Main(string[] args)
        {
            //新建服务器，并绑定服务
            Server server = new Server
            {
                Services = { EventReporting.BindService(new EventReporttingImpl()) },
                Ports = { new ServerPort("localhost", Port, ServerCredentials.Insecure) }
            };
            server.Start();

            Console.WriteLine("Greeter server listening on port " + Port);
            Console.WriteLine("Press any key to stop the server...");
            Console.ReadKey();

            server.ShutdownAsync().Wait();
        }
    }
}
```

其他语言的客户端与服务端实现请参考GRPC官方文档。

