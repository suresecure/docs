---
title: 深度学习服务器接口说明
author: 湖南戍融智能科技有限公司
date: 20170227
institute: 戍融智能 
toc-title: 目录

---

#软件接口

接口为RESTFUL API

http://ip:port/person_detection

使用curl工具访问的命令如下：

'''sh
curl –X POST http://ip:port/person_detection -F image=@xx.jpg
'''

其中xx.jpg为本地一个图片文件

返回为json数据，形式如下：

'''json
{"targets":
	[
	{"y": 2, "x": 1, "w": 3, "h": 4, "label": "call", "conf": 96,}
	{"y": 2, "x": 1, "w": 3, "h": 4, "label": "hat", "conf": 96,}
	]
}
'''

其中targets为一个数组，每项中的x、y、w、h分别表示在图片中检测到目标的左上角坐标与宽和高，label表示该目标的类型，call表示该目标为打电话（目前在浩云部署的服务器只会返回这一种label），conf表示该目标的置信度，取值范围0-100.

#功能

目前功能分为三类：

第一类为人员检测，软件接口中返回的label值为person，表示一个人员目标

第二类为打电话检测，软件接口中返回的label值为call，表示一个打电话动作，该动作检测必须针对ATM正面人脸所拍摄的照片，并且只能检测打电话人员举手打电话的动作，如果仅仅侧头夹着电话无法检测。

第三类为异常人脸，包括四种子类型，label值分别为：

hat，帽子，指鸭舌帽。

sunglasses，墨镜。

mask，口罩，包括用手遮挡脸部，或是用纸等其他物体遮挡脸部。

helmet，头盔，指一般骑摩托车或是电动车所佩戴的安全头盔，不包含面具。

人员检测最小尺寸：对于800x600的输入图像，人员目标不能小于40x40，其他分辨率尺寸以此类推，另外人员在图像中需要是正的，例如不能将摄像头侧着放，导致人员横着。

打电话、异常人脸检测最小尺寸：对于704x576的输入图像，目标人头在画面中所占尺寸不能小于120x80，其他分辨率尺寸以此类推。

#性能

计算性能：进行人员检测时，每张显卡每秒钟可以处理约6幅输入图像，进行打电话或是异常人脸检测时，每秒钟可以处理大于16幅输入图像。

总体精度指标：

人员检测，大于98%

打电话检测，大于97%

异常人脸-帽子，大于97%

异常人脸-墨镜，大于98%

异常人脸-口罩，大于97%

异常人脸-头盔，大于99%