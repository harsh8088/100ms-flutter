import 'package:flutter/material.dart';
import 'package:hms_room_kit/hms_room_kit.dart';
import 'package:hms_room_kit/src/meeting/meeting_store.dart';
import 'package:hms_room_kit/src/model/poll_store.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/hms_button.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/hms_subheading_text.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';

class PollVoteCard extends StatefulWidget {
  final int questionNumber;
  final int totalQuestions;
  final HMSPollQuestion question;

  const PollVoteCard(
      {super.key,
      required this.questionNumber,
      required this.totalQuestions,
      required this.question});

  @override
  State<PollVoteCard> createState() => _PollVoteCardState();
}

class _PollVoteCardState extends State<PollVoteCard> {
  HMSPollQuestionOption? selectedOption;
  List<HMSPollQuestionOption> selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: HMSThemeColors.surfaceDefault,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  HMSTitleText(
                      text:
                          "QUESTION ${widget.questionNumber + 1} OF ${widget.totalQuestions}: ",
                      textColor: HMSThemeColors.onSurfaceLowEmphasis,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      lineHeight: 16),
                  HMSTitleText(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      lineHeight: 16,
                      text: Utilities.getQuestionType(widget.question.type),
                      textColor: HMSThemeColors.onSurfaceLowEmphasis)
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              HMSTitleText(
                text: widget.question.text,
                textColor: HMSThemeColors.onSurfaceHighEmphasis,
                maxLines: 3,
                fontWeight: FontWeight.w400,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.question.options.length,
                  itemBuilder: (BuildContext context, index) {
                    return Row(
                      children: [
                        Checkbox(
                            activeColor: HMSThemeColors.onSurfaceHighEmphasis,
                            checkColor: HMSThemeColors.surfaceDefault,
                            value: ((widget.question.type ==
                                    HMSPollQuestionType.singleChoice)
                                ? selectedOption ==
                                    widget.question.options[index]
                                : selectedOptions
                                    .contains(widget.question.options[index])),
                            shape: widget.question.type ==
                                    HMSPollQuestionType.singleChoice
                                ? const CircleBorder()
                                : const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                            onChanged: (value) {
                              if (value == true) {
                                if (widget.question.type ==
                                    HMSPollQuestionType.singleChoice) {
                                  selectedOption =
                                      widget.question.options[index];
                                } else if (widget.question.type ==
                                    HMSPollQuestionType.multiChoice) {
                                  selectedOptions
                                      .add(widget.question.options[index]);
                                }
                              } else {
                                if (widget.question.type ==
                                    HMSPollQuestionType.multiChoice) {
                                  selectedOptions
                                      .remove(widget.question.options[index]);
                                }
                              }

                              setState(() {});
                            }),
                        Expanded(
                          child: HMSSubheadingText(
                              text: widget.question.options[index].text ?? "",
                              textColor: HMSThemeColors.onSurfaceHighEmphasis),
                        )
                      ],
                    );
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  HMSButton(
                      width: 88,
                      onPressed: () {
                        if (widget.question.type ==
                                HMSPollQuestionType.singleChoice &&
                            selectedOption != null) {
                          context
                              .read<MeetingStore>()
                              .addSingleChoicePollResponse(
                                  context.read<HMSPollStore>().poll,
                                  widget.question,
                                  selectedOption!);
                        } else if (widget.question.type ==
                                HMSPollQuestionType.multiChoice &&
                            selectedOptions.isNotEmpty) {
                          context
                              .read<MeetingStore>()
                              .addMultiChoicePollResponse(
                                  context.read<HMSPollStore>().poll,
                                  widget.question,
                                  selectedOptions);
                        }
                      },
                      childWidget: HMSTitleText(
                          text: "Vote",
                          textColor: HMSThemeColors.onSurfaceHighEmphasis))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
