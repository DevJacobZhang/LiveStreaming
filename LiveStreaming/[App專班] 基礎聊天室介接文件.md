# [App專班] wsocket基礎聊天室介接文件

## 連線
#### 連線網址
連線網址除暱稱query外，其他參數請不要更動
```
wss://lott-dev.lottcube.asia/ws/chat/chat:app_test?nickname={自定義暱稱}
```
#### 連線檢測方式
>若連線連不上，請先檢查連線參數或網址是否帶錯，可使用線上測試工具輔助檢測

發送
```json
ping
```
收到
```json
pong
```

## 訊息格式
沒有寫註解且沒有值的欄位不用管
#### 事件固定格式
```json
{
    "event":"default_message",              // 事件類型
    "room_id":"chat:app_test",              // 房間ID
    "sender_role":4,                        // 發話者來源
    "body":{},                              // 內容，依據事件類型結構可能都不同
    "time":"1645500950878669900"            // 時間戳
}

```
#### 系統屏蔽字元，以逗號分割

訊息經過聊天室服務後會被過濾掉的字元
```
" ,~,!,#,$,%,^,&,*,(,),_,-,+,=,?,<,>,.,—,，,。,/,\\,|,《,》,？,;,:,：,',‘,；,“,"
```
### 發送訊息
#### 一般發話
```json
{
    "action": "N",                     // 訊息類型，只有N是訪客能使用的，其餘都發不出去 
    "content": "測試測試測試測試測試測試"  // 訊息文字內容
}
```
### 接收訊息
#### 無效的訊息類型
```json
{
    "event":"undefined"
}
```
#### 一般發話 [default_message]
```json
{
    "event":"default_message",              // 事件類型：一般發話
    "room_id":"chat:app_test",              // 房間ID
    "sender_role":-1,                        // 發話者來源：自訂訪客
    "body":{
        "chat_id":"Np5zcTgsKXRMhAHA8GbWsb", // 發話者uuid，每次進連線自動產生
        "account":"Np5zcTgsKXRMhAHA8GbWsb",
        "nickname":"test1",                 // 發話者暱稱
        "recipient":"",
        "type":"N",                         // 訊息類型
        "text":"測試測試測試測試測試測試",      // 訊息內容
        "accept_time":"1645500950878612400", // 服務接收到用戶發話的時間(unixNano)
        "info":{
            "last_login":1645500887,        // 該用戶進入連線的時間戳(unix)
            "is_ban":0,
            "level":1,
            "is_guardian":0,
            "badges":null
        }
        
    },
    "time":"1645500950878669900"           // 時間戳：服務廣播訊息的時間(unixNano)
}
```
#### 進出更新通知 [sys_updateRoomStatus]
```json
{
    "event":"sys_updateRoomStatus",
    "room_id":"chat:app_test",
    "sender_role":0,
    "body":{
        "entry_notice":{
            "username":"test2",     // 用戶暱稱
            "head_photo":"",
            "action":"enter",       // 動作類別：enter(進入)、leave(離開)
            "entry_banner":{
                "present_type":"",
                "img_url":"",
                "main_badge":"",
                "other_badges":[]    
            }
        },
        "room_count":456, // 灌水在線人數
        "real_count":6,   // 真實在線人數
        "user_infos":{
            "guardianlist":[],
            "onlinelist":null
        },
        "guardian_count":0,
        "guardian_sum":0,
        "contribute_sum":0
    },
    "time":"1645503136460420600"
}
```
#### 系統廣播 [admin_all_broadcast]
```json
{
    "event":"admin_all_broadcast",
    "room_id":"chat:all",
    "sender_role":5,   // 發話者來源：系統
    "body":{
        "content":{    // 訊息內容
            "cn":"英語內容",
            "en":"簡體內容",
            "tw":"繁體內容"
        }
    },
    "time":"1645503300012957315"
}

```

#### 房間關閉 [sys_room_endStream]
收到該事件時聊天室會由服務執行斷線
```json
{
    "event":"sys_room_endStream",
    "room_id":"chat:app_test",
    "sender_role":5,
    "body":{
        "type":"C",
        "text":"直播間已關閉"     // 或是：系統中斷
    },
    "time":"1630289435866278121"
}
```

## 節目表範例

- head_photo 頭貼
- nickname 暱稱
- online_num 人數
- stream_title 直播標題
- tags 標籤

```json
{"error_code":"0","error_text":"","result":{"lightyear_list":[{"stream_id":5015,"streamer_id":88928,"stream_title":"水水姑娘回来到","status":2,"open_at":1646719585,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"水水","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644397354.png","tags":"陪玩,哥哥快来","online_num":5008,"game":"LT-PAO1MLT-1","charge":50,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644397369.png","open_attention":true,"open_guardians":true},{"stream_id":5013,"streamer_id":88999,"stream_title":"可比","status":2,"open_at":1646719140,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"可比","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644377119.png","tags":"哥哥快来","online_num":5240,"game":"LT-PAO1MLT-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644377383.png","open_attention":true,"open_guardians":false},{"stream_id":5019,"streamer_id":4,"stream_title":"你的小可爱已上线","status":2,"open_at":1646720723,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"乐乐","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1646720583.png","tags":"疗愈系,哥哥快来","online_num":5028,"game":"SICBO-PAOFSC-1","charge":10,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1646720599.png","open_attention":true,"open_guardians":true},{"stream_id":5018,"streamer_id":89030,"stream_title":"感冒不大能說話","status":2,"open_at":1646720663,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"跳跳","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644428619.png","tags":"疗愈系,性感","online_num":5043,"game":"SICBO-PAOFSC-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644428867.png","open_attention":true,"open_guardians":true},{"stream_id":5011,"streamer_id":88975,"stream_title":"Hi","status":2,"open_at":1646719057,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"Bee","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645682209.png","tags":"陪玩","online_num":5110,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644346570.png","open_attention":true,"open_guardians":true},{"stream_id":5007,"streamer_id":88952,"stream_title":"下午好","status":2,"open_at":1646716949,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"凌晨🌛","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645517728.png","tags":"女神","online_num":5216,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645517798.png","open_attention":true,"open_guardians":false},{"stream_id":5016,"streamer_id":88954,"stream_title":"❤❤❤","status":2,"open_at":1646719748,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"妍淨","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644471854.png","tags":"女神,高颜值","online_num":5024,"game":"LT-PAO1MLT-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":false},{"stream_id":5014,"streamer_id":88976,"stream_title":"快三","status":2,"open_at":1646719149,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"佳佳","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645797071.png","tags":"带投","online_num":5034,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644333668.png","open_attention":true,"open_guardians":true},{"stream_id":5010,"streamer_id":88961,"stream_title":"燕窩","status":2,"open_at":1646717698,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"燕子","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644385399.png","tags":"","online_num":5100,"game":"E5-PAOE5-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":false},{"stream_id":5012,"streamer_id":88927,"stream_title":"大口吃肉肉","status":2,"open_at":1646719122,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"肉肉","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644397286.png","tags":"大秀,疗愈系","online_num":5025,"game":"E5-PAOE5-1","charge":10,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644397298.png","open_attention":true,"open_guardians":true},{"stream_id":4971,"streamer_id":89056,"stream_title":"福利群介绍","status":2,"open_at":1646701205,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"直播小帮手","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645294011.png","tags":"中国好声音","online_num":7742,"game":"PK-PAOPK-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645294024.png","open_attention":true,"open_guardians":true},{"stream_id":5020,"streamer_id":89033,"stream_title":"一起冒險","status":2,"open_at":1646721083,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"小檸檬","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644481213.png","tags":"可盐可甜,哥哥快来","online_num":5016,"game":"SC-PAO1MSC-1","charge":3,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":true},{"stream_id":5003,"streamer_id":88992,"stream_title":"暖暖","status":2,"open_at":1646716192,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"暖暖","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644324926.png","tags":"疗愈系,女神","online_num":5132,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644578697.png","open_attention":true,"open_guardians":false},{"stream_id":5008,"streamer_id":88996,"stream_title":"新主播","status":2,"open_at":1646717002,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"安苡萱","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644390202.png","tags":"","online_num":5217,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644389880.png","open_attention":true,"open_guardians":false},{"stream_id":4972,"streamer_id":89057,"stream_title":"道具卡介绍","status":2,"open_at":1646701332,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"直播小帮手","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645122865.png","tags":"中国好声音","online_num":15342,"game":"SICBO-PAOFSC-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645122818.png","open_attention":true,"open_guardians":true},{"stream_id":5017,"streamer_id":88903,"stream_title":"來","status":2,"open_at":1646720546,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"錢錢","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644337896.png","tags":"带投,嫩模","online_num":5005,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644338003.png","open_attention":true,"open_guardians":false}],"stream_list":[{"stream_id":5007,"streamer_id":88952,"stream_title":"下午好","status":2,"open_at":1646716949,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"凌晨🌛","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645517728.png","tags":"女神","online_num":5216,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645517798.png","open_attention":true,"open_guardians":false},{"stream_id":5018,"streamer_id":89030,"stream_title":"感冒不大能說話","status":2,"open_at":1646720663,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"跳跳","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644428619.png","tags":"疗愈系,性感","online_num":5043,"game":"SICBO-PAOFSC-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644428867.png","open_attention":true,"open_guardians":true},{"stream_id":5012,"streamer_id":88927,"stream_title":"大口吃肉肉","status":2,"open_at":1646719122,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"肉肉","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644397286.png","tags":"大秀,疗愈系","online_num":5025,"game":"E5-PAOE5-1","charge":10,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644397298.png","open_attention":true,"open_guardians":true},{"stream_id":5015,"streamer_id":88928,"stream_title":"水水姑娘回来到","status":2,"open_at":1646719585,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"水水","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644397354.png","tags":"陪玩,哥哥快来","online_num":5008,"game":"LT-PAO1MLT-1","charge":50,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644397369.png","open_attention":true,"open_guardians":true},{"stream_id":5019,"streamer_id":4,"stream_title":"你的小可爱已上线","status":2,"open_at":1646720723,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"乐乐","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1646720583.png","tags":"疗愈系,哥哥快来","online_num":5028,"game":"SICBO-PAOFSC-1","charge":10,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1646720599.png","open_attention":true,"open_guardians":true},{"stream_id":5003,"streamer_id":88992,"stream_title":"暖暖","status":2,"open_at":1646716192,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"暖暖","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644324926.png","tags":"疗愈系,女神","online_num":5132,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644578697.png","open_attention":true,"open_guardians":false},{"stream_id":4971,"streamer_id":89056,"stream_title":"福利群介绍","status":2,"open_at":1646701205,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"直播小帮手","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645294011.png","tags":"中国好声音","online_num":7742,"game":"PK-PAOPK-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645294024.png","open_attention":true,"open_guardians":true},{"stream_id":5010,"streamer_id":88961,"stream_title":"燕窩","status":2,"open_at":1646717698,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"燕子","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644385399.png","tags":"","online_num":5100,"game":"E5-PAOE5-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":false},{"stream_id":5008,"streamer_id":88996,"stream_title":"新主播","status":2,"open_at":1646717002,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"安苡萱","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644390202.png","tags":"","online_num":5217,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644389880.png","open_attention":true,"open_guardians":false},{"stream_id":5020,"streamer_id":89033,"stream_title":"一起冒險","status":2,"open_at":1646721083,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"小檸檬","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644481213.png","tags":"可盐可甜,哥哥快来","online_num":5016,"game":"SC-PAO1MSC-1","charge":3,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":true},{"stream_id":4972,"streamer_id":89057,"stream_title":"道具卡介绍","status":2,"open_at":1646701332,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"直播小帮手","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645122865.png","tags":"中国好声音","online_num":15342,"game":"SICBO-PAOFSC-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645122818.png","open_attention":true,"open_guardians":true},{"stream_id":5013,"streamer_id":88999,"stream_title":"可比","status":2,"open_at":1646719140,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"可比","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644377119.png","tags":"哥哥快来","online_num":5240,"game":"LT-PAO1MLT-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644377383.png","open_attention":true,"open_guardians":false},{"stream_id":5016,"streamer_id":88954,"stream_title":"❤❤❤","status":2,"open_at":1646719748,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"妍淨","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644471854.png","tags":"女神,高颜值","online_num":5024,"game":"LT-PAO1MLT-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":false},{"stream_id":5007,"streamer_id":88952,"stream_title":"下午好","status":2,"open_at":1646716949,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"凌晨🌛","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645517728.png","tags":"女神","online_num":5216,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645517798.png","open_attention":true,"open_guardians":false},{"stream_id":5014,"streamer_id":88976,"stream_title":"快三","status":2,"open_at":1646719149,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"佳佳","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645797071.png","tags":"带投","online_num":5034,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644333668.png","open_attention":true,"open_guardians":true},{"stream_id":5011,"streamer_id":88975,"stream_title":"Hi","status":2,"open_at":1646719057,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"Bee","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645682209.png","tags":"陪玩","online_num":5110,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644346570.png","open_attention":true,"open_guardians":true},{"stream_id":5017,"streamer_id":88903,"stream_title":"來","status":2,"open_at":1646720546,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"錢錢","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644337896.png","tags":"带投,嫩模","online_num":5005,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644338003.png","open_attention":true,"open_guardians":false},{"stream_id":5015,"streamer_id":88928,"stream_title":"水水姑娘回来到","status":2,"open_at":1646719585,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"水水","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644397354.png","tags":"陪玩,哥哥快来","online_num":5008,"game":"LT-PAO1MLT-1","charge":50,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644397369.png","open_attention":true,"open_guardians":true},{"stream_id":5013,"streamer_id":88999,"stream_title":"可比","status":2,"open_at":1646719140,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"可比","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644377119.png","tags":"哥哥快来","online_num":5240,"game":"LT-PAO1MLT-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644377383.png","open_attention":true,"open_guardians":false},{"stream_id":5019,"streamer_id":4,"stream_title":"你的小可爱已上线","status":2,"open_at":1646720723,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"乐乐","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1646720583.png","tags":"疗愈系,哥哥快来","online_num":5028,"game":"SICBO-PAOFSC-1","charge":10,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1646720599.png","open_attention":true,"open_guardians":true},{"stream_id":5018,"streamer_id":89030,"stream_title":"感冒不大能說話","status":2,"open_at":1646720663,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"跳跳","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644428619.png","tags":"疗愈系,性感","online_num":5043,"game":"SICBO-PAOFSC-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644428867.png","open_attention":true,"open_guardians":true},{"stream_id":5011,"streamer_id":88975,"stream_title":"Hi","status":2,"open_at":1646719057,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"Bee","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645682209.png","tags":"陪玩","online_num":5110,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644346570.png","open_attention":true,"open_guardians":true},{"stream_id":5007,"streamer_id":88952,"stream_title":"下午好","status":2,"open_at":1646716949,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"凌晨🌛","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645517728.png","tags":"女神","online_num":5216,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645517798.png","open_attention":true,"open_guardians":false},{"stream_id":5016,"streamer_id":88954,"stream_title":"❤❤❤","status":2,"open_at":1646719748,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"妍淨","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644471854.png","tags":"女神,高颜值","online_num":5024,"game":"LT-PAO1MLT-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":false},{"stream_id":5014,"streamer_id":88976,"stream_title":"快三","status":2,"open_at":1646719149,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"佳佳","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645797071.png","tags":"带投","online_num":5034,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644333668.png","open_attention":true,"open_guardians":true},{"stream_id":5010,"streamer_id":88961,"stream_title":"燕窩","status":2,"open_at":1646717698,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"燕子","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644385399.png","tags":"","online_num":5100,"game":"E5-PAOE5-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":false},{"stream_id":5012,"streamer_id":88927,"stream_title":"大口吃肉肉","status":2,"open_at":1646719122,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"肉肉","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644397286.png","tags":"大秀,疗愈系","online_num":5025,"game":"E5-PAOE5-1","charge":10,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644397298.png","open_attention":true,"open_guardians":true},{"stream_id":4971,"streamer_id":89056,"stream_title":"福利群介绍","status":2,"open_at":1646701205,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"直播小帮手","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645294011.png","tags":"中国好声音","online_num":7742,"game":"PK-PAOPK-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645294024.png","open_attention":true,"open_guardians":true},{"stream_id":5020,"streamer_id":89033,"stream_title":"一起冒險","status":2,"open_at":1646721083,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"小檸檬","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644481213.png","tags":"可盐可甜,哥哥快来","online_num":5016,"game":"SC-PAO1MSC-1","charge":3,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube-dev/develop/1/backgroundImage/preset.jpg","open_attention":true,"open_guardians":true},{"stream_id":5003,"streamer_id":88992,"stream_title":"暖暖","status":2,"open_at":1646716192,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"暖暖","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644324926.png","tags":"疗愈系,女神","online_num":5132,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644578697.png","open_attention":true,"open_guardians":false},{"stream_id":5008,"streamer_id":88996,"stream_title":"新主播","status":2,"open_at":1646717002,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"安苡萱","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644390202.png","tags":"","online_num":5217,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644389880.png","open_attention":true,"open_guardians":false},{"stream_id":4972,"streamer_id":89057,"stream_title":"道具卡介绍","status":2,"open_at":1646701332,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"直播小帮手","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1645122865.png","tags":"中国好声音","online_num":15342,"game":"SICBO-PAOFSC-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1645122818.png","open_attention":true,"open_guardians":true},{"stream_id":5017,"streamer_id":88903,"stream_title":"來","status":2,"open_at":1646720546,"closed_at":0,"deleted_at":0,"start_time":0,"nickname":"錢錢","head_photo":"https://storage.googleapis.com/lottcube/production/1/headphoto/headphoto1644337896.png","tags":"带投,嫩模","online_num":5005,"game":"Q3-PAOQ3-1","charge":0,"group_id":0,"background_image":"https://storage.googleapis.com/lottcube/production/1/backgroundImage/backgroundImage1644338003.png","open_attention":true,"open_guardians":false}]}}
```