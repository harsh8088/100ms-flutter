package live.hms.hmssdk_flutter

import android.util.Log
import live.hms.video.sdk.models.HMSRoom

class HMSRoomExtension {
    companion object{
        fun toDictionary(room:HMSRoom?):HashMap<String,Any>?{
            val hashMap=HashMap<String,Any>()

            if (room==null)return null
            hashMap.put("id",room.roomId )
            hashMap.put("name",room.name)
            hashMap.put("meta_data","")
            //hashMap.put("local_peer", HMSPeerExtension.toDictionary(room.localPeer)!!)

            val args=ArrayList<Any>()
            room.peerList.forEach {
                args.add(HMSPeerExtension.toDictionary(it)!!)
            }
            hashMap.put("peers",args)
            Log.i("HMSROOMEXTENSION",hashMap.toString())

            val roomMap=HashMap<String,Any>()
            roomMap.put("room",hashMap)
            return roomMap
        }
    }
}