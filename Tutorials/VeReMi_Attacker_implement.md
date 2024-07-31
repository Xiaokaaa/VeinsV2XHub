## VeReMi中的五种攻击类型实现方法

### 项目来源
- [Paper: https://arxiv.org/abs/1804.06701](https://arxiv.org/abs/1804.06701)
- [GitHub: https://github.com/VeReMi-dataset](https://github.com/VeReMi-dataset)
- [https://veremi-dataset.github.io/](https://veremi-dataset.github.io/)


### 攻击场景描述
攻击具体情况如下：

<div style="text-align: center;">
<img src="images/VeReMi_Attacker_implement_images/cjms.png" alt="Alt text" style="width: 100%;">
</div>


#### 场景描述
- Constant：车辆广播固定位置（5560, 5820）
- Constant offset：车辆广播真实位置+固定偏移（x+250, y-150）
- Random：车辆广播地图区域随机位置
- Random offset：车辆广播真实位置+随机偏移（x+▲, y+▲）
- Eventual stop：重复发送当前位置，就像已经停止了一样，就是位置伪造攻击


### Veins-SUMO-OMNeT++代码实现
```cpp
// TraCIDemo11p.cc

void TraCIDemo11p::initialize(int stage)
{
    DemoBaseApplLayer::initialize(stage);
    if (stage == 0) {

    }
    if (stage == 1) {
        random_device rd;
        mt19937 gen(rd());
        bernoulli_distribution bd_mal(0.2); //车辆是否恶意，服从伯努利分布，恶意概率0.2
        isMalicious = bd_mal(gen);

        if (isMalicious) { // 恶意车辆ID初始化
            RID = myId;
            VID = generateVID(myId);    // generateVID(myId)，伪ID生成函数，可以自己设计
        } else { // 正常车辆ID初始化
            RID = myId;
        }
    }
}

void TraCIDemo11p::handlePositionUpdate(cObject* obj)
{
    DemoBaseApplLayer::handlePositionUpdate(obj);

    // 真实beacon消息内容
    double pos_x = mobility->getPositionAt(simTime()).x;
    double pos_y = mobility->getPositionAt(simTime()).y;
    double timestamp = simTime().dbl();

    ostringstream oss;
    string beaconMsg;

    if (!isMalicious) { // 正常车辆行为

        oss << RID << "||" << pos_x << "||" << pos_y << "||" << timestamp;
        beaconMsg = oss.str();
        cout << "正常车辆[" << RID << "]广播位置：" << beaconMsg << endl;
    }

    if (isMalicious) {  // 恶意节点行为

        int MalBehaviorSelect = generateRandomNumber(); // 随机恶意行为选择 1-4

        if (MalBehaviorSelect == 1) { // 恶意节点行为1：广播固定位置（其实在动，却告诉别人不动）

            oss << VID << "||" << 0 << "||" << 0 << "||" << timestamp; // 固定位置可自行更改，这里以全0值为例
            beaconMsg = oss.str();
            cout << "恶意行为1：" << "恶意车辆[" << RID << "]广播固定位置：" << beaconMsg << endl;

        } else if (MalBehaviorSelect == 2) { // 恶意节点行为2：广播随机位置（地图上任意点）
            Coord vpos = generateRandomPosition(2500, 2500); // 这里是地图最大x,y，以2500m为例
            pos_x = vpos.x;
            pos_y = vpos.y;
            timestamp = simTime().dbl();

            oss << VID << "||" << pos_x << "||" << pos_y << "||" << timestamp;
            beaconMsg = oss.str();
            cout << "恶意行为2：" << "恶意车辆[" << RID << "]广播随机位置：" << beaconMsg << endl;

        } else if (MalBehaviorSelect == 3) { // 恶意节点行为3：广播真实位置+固定偏移
            double pos_x_add = 10; // 固定偏移量
            double pos_y_add = 10;
            timestamp = simTime().dbl();

            oss << VID << "||" << pos_x + pos_x_add  << "||" << pos_y + pos_y_add << "||" << timestamp;
            beaconMsg = oss.str();
            cout << "恶意行为3：" << "恶意车辆[" << RID << "]广播真实位置+固定偏移：" << beaconMsg << endl;

        } else if (MalBehaviorSelect == 4) { // 恶意节点行为4：广播真实位置+随机偏移
            Coord vpos = generateRandomPosition(2500, 2500); // 生成随机0-2500的偏移量
            double pos_x_add = vpos.x;
            double pos_y_add = vpos.y;
            timestamp = simTime().dbl();

            oss << VID << "||" << pos_x + pos_x_add  << "||" << pos_y + pos_y_add << "||" << timestamp;
            beaconMsg = oss.str();
            cout << "恶意行为4：" << "恶意车辆[" << RID << "]广播真实位置+随机偏移：" << beaconMsg << endl;

        } else { // 可扩展设置默认恶意行为

        }

    }

    // 打包消息
    TraCIDemo11pMessage* newWSM = new TraCIDemo11pMessage();
    populateWSM(newWSM);
    newWSM->setMsgData(beaconMsg.data());
    sendDelayedDown(newWSM->dup(), uniform(0.01, 0.1));

    delete newWSM;
}
```
通过这个基础的代码实现，大家就可以扩展功能，定义自己的数据集啦~👏 

