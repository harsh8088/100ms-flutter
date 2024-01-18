package live.hms.hmssdk_flutter.poll_extension

import live.hms.video.polls.models.answer.HMSPollQuestionAnswer

class HMSPollQuestionAnswerExtension {

    companion object {
        fun toDictionary(answer: HMSPollQuestionAnswer?):HashMap<String,Any?>?{
            answer?.let {
                val map = HashMap<String,Any?>()
                map["hidden"] = it.hidden
                map["option"] = it.option
                map["options"] = it.options
                return map
            }?:run{
                return null
            }
        }
    }
}