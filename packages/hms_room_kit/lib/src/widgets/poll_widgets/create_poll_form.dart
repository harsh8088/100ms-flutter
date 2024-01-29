import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hms_room_kit/hms_room_kit.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/hms_dropdown.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/hms_subheading_text.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:tuple/tuple.dart';

class CreatePollForm extends StatefulWidget {
  final int questionNumber;
  final int totalQuestions;
  final HMSPollQuestionType questionType;
  final TextEditingController questionController;
  final List<TextEditingController> optionsTextController;
  final HMSPollQuestionBuilder questionBuilder;
  final Function deleteQuestionCallback;
  final Function savePollCallback;
  const CreatePollForm(
      {super.key,
      required this.questionNumber,
      required this.totalQuestions,
      required this.questionType,
      required this.optionsTextController,
      required this.questionController,
      required this.questionBuilder,
      required this.deleteQuestionCallback,
      required this.savePollCallback});

  @override
  State<CreatePollForm> createState() => _CreatePollFormState();
}

class _CreatePollFormState extends State<CreatePollForm> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionsTextController;
  bool _isSkippable = false;
  bool _canChangeResponse = false;

  List<Tuple2<String, HMSPollQuestionType>> getPollQuestionType() {
    return const [
      Tuple2("Single Choice", HMSPollQuestionType.singleChoice),
      Tuple2("Multiple Choice", HMSPollQuestionType.multiChoice)
    ];
  }

  @override
  void initState() {
    _questionController = widget.questionController;
    if (widget.optionsTextController.isEmpty) {
      _optionsTextController = [
        TextEditingController(),
        TextEditingController()
      ];
    } else {
      _optionsTextController = widget.optionsTextController;
    }
    super.initState();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var element in _optionsTextController) {
      element.dispose();
    }
    super.dispose();
  }

  void setIsSkippable(value) {
    widget.questionBuilder.withCanSkip = value;
    setState(() {
      _isSkippable = value;
    });
  }

  void setCanChangeResponse(value) {
    widget.questionBuilder.withCanChangeResponse = value;
    setState(() {
      _canChangeResponse = value;
    });
  }

  void _addOption() {
    _optionsTextController.add(TextEditingController());
    setState(() {});
  }

  bool _isPollValid() {
    bool areOptionsFilled = _optionsTextController.length >= 2;
    for (var optionController in _optionsTextController) {
      areOptionsFilled = areOptionsFilled && (optionController.text.isNotEmpty);
    }
    return (areOptionsFilled && _questionController.text.isNotEmpty);
  }

  void _setTitle(String title) {
    widget.questionBuilder.withTitle = title;
  }

  void _savePollOption(String option, int index) {
    _optionsTextController[index].text = option;
  }

  void saveQuestion() {
    widget.questionBuilder.withOption = _optionsTextController.map((e) => e.text).toList();
    if (_isPollValid()) {
      widget.savePollCallback(widget.questionBuilder);
    }
  }

  void _updatePollType(HMSPollQuestionType questionType) {
    widget.questionBuilder.withType = questionType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            HMSTitleText(
                text:
                    "QUESTION ${widget.questionNumber + 1} OF ${widget.totalQuestions}",
                textColor: HMSThemeColors.onSurfaceLowEmphasis,
                fontSize: 10,
                letterSpacing: 1.5,
                lineHeight: 16),
            const SizedBox(
              height: 8,
            ),
            HMSSubheadingText(
              text: "Question Type",
              textColor: HMSThemeColors.onSurfaceHighEmphasis,
            ),
            const SizedBox(
              height: 8,
            ),
            DropdownButtonHideUnderline(
                child: HMSDropDown(
                    dropDownItems: getPollQuestionType()
                        .map((e) => DropdownMenuItem(
                              value: e.item2,
                              child: HMSTitleText(
                                text: e.item1,
                                textColor: HMSThemeColors.onSurfaceHighEmphasis,
                                fontWeight: FontWeight.w400,
                              ),
                            ))
                        .toList(),
                    buttonStyleData: ButtonStyleData(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: HMSThemeColors.surfaceBright,
                          borderRadius: BorderRadius.circular(8),
                        )),
                    dropdownStyleData: DropdownStyleData(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: HMSThemeColors.surfaceBright,
                        )),
                    selectedValue: widget.questionType,
                    updateSelectedValue: (value) {
                      _updatePollType(value);
                    })),
            const SizedBox(
              height: 8,
            ),
            HMSSubheadingText(
              text: "Question",
              textColor: HMSThemeColors.onSurfaceHighEmphasis,
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 48,
              child: TextField(
                cursorColor: HMSThemeColors.onSurfaceHighEmphasis,
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                style: HMSTextStyle.setTextStyle(
                    color: HMSThemeColors.onSurfaceHighEmphasis),
                controller: _questionController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  _setTitle(value.trim());
                  setState(() {});
                },
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    fillColor: HMSThemeColors.surfaceBright,
                    filled: true,
                    hintText: "e.g. Who will win the match?",
                    hintStyle: HMSTextStyle.setTextStyle(
                        color: HMSThemeColors.onSurfaceLowEmphasis,
                        height: 1.5,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w400),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        borderSide:
                            BorderSide(color: HMSThemeColors.primaryDefault)),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none)),
              ),
            ),
            const SizedBox(
              height: 8,
            ),

            ///Divider
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: Divider(
                height: 5,
                color: HMSThemeColors.borderBright,
              ),
            ),

            HMSSubheadingText(
              text: "Options",
              textColor: HMSThemeColors.onSurfaceHighEmphasis,
            ),

            const SizedBox(
              height: 8,
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _optionsTextController.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 48,
                          width: MediaQuery.of(context).size.width * 0.67,
                          child: TextField(
                            cursorColor: HMSThemeColors.onSurfaceHighEmphasis,
                            onTapOutside: (event) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.words,
                            style: HMSTextStyle.setTextStyle(
                                color: HMSThemeColors.onSurfaceHighEmphasis),
                            controller: _optionsTextController[index],
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              _savePollOption(value.trim(), index);
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                fillColor: HMSThemeColors.surfaceBright,
                                filled: true,
                                hintText: "Option ${index + 1}",
                                hintStyle: HMSTextStyle.setTextStyle(
                                    color: HMSThemeColors.onSurfaceLowEmphasis,
                                    height: 1.5,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w400),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    borderSide: BorderSide(
                                        color: HMSThemeColors.primaryDefault)),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                          ),
                        ),
                        if (_optionsTextController.length > 2)
                          IconButton(
                              onPressed: () {
                                _optionsTextController.removeAt(index);
                                setState(() {});
                              },
                              icon: SvgPicture.asset(
                                  "packages/hms_room_kit/lib/src/assets/icons/delete_poll.svg",
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                      HMSThemeColors.onSurfaceLowEmphasis,
                                      BlendMode.srcIn)))
                      ],
                    ),
                  );
                }),
            if (_optionsTextController.length < 8)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    _addOption();
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                          "packages/hms_room_kit/lib/src/assets/icons/add_option.svg",
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                              HMSThemeColors.onSurfaceMediumEmphasis,
                              BlendMode.srcIn)),
                      const SizedBox(
                        width: 16,
                      ),
                      HMSSubheadingText(
                        text: "Add an option",
                        textColor: HMSThemeColors.onSurfaceMediumEmphasis,
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
              ),
              child: Divider(
                height: 5,
                color: HMSThemeColors.borderBright,
              ),
            ),

            ListTile(
              horizontalTitleGap: 1,
              enabled: false,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: HMSSubheadingText(
                  text: "Allow to skip",
                  textColor: HMSThemeColors.onSurfaceMediumEmphasis),
              trailing: SizedBox(
                height: 24,
                width: 40,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CupertinoSwitch(
                    value: _isSkippable,
                    onChanged: (value) => setIsSkippable(value),
                    activeColor: HMSThemeColors.primaryDefault,
                  ),
                ),
              ),
            ),

            ListTile(
              horizontalTitleGap: 1,
              enabled: false,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: HMSSubheadingText(
                  text: "Allow to vote again",
                  textColor: HMSThemeColors.onSurfaceMediumEmphasis),
              trailing: SizedBox(
                height: 24,
                width: 40,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CupertinoSwitch(
                    value: _canChangeResponse,
                    onChanged: (value) => setIsSkippable(value),
                    activeColor: HMSThemeColors.primaryDefault,
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // if (widget.totalQuestions > 1)
                //   HMSEmbeddedButton(
                //     onTap: () => {},
                //     // widget.deleteQuestionCallback(widget.questionBuilder),
                //     isActive: true,
                //     onColor: HMSThemeColors.surfaceDefault,
                //     child: SvgPicture.asset(
                //       "packages/hms_room_kit/lib/src/assets/icons/delete_poll.svg",
                //       colorFilter: ColorFilter.mode(
                //           HMSThemeColors.onSurfaceHighEmphasis,
                //           BlendMode.srcIn),
                //       fit: BoxFit.scaleDown,
                //     ),
                //   ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor: (_questionController.text.isNotEmpty)
                            ? MaterialStateProperty.all(
                                HMSThemeColors.secondaryDefault)
                            : MaterialStateProperty.all(
                                HMSThemeColors.secondaryDim),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ))),
                    onPressed: () {
                      saveQuestion();
                    },
                    child: HMSTitleText(
                        text: "Save",
                        textColor: _isPollValid()
                            ? HMSThemeColors.onSecondaryHighEmphasis
                            : HMSThemeColors.onSecondaryLowEmphasis))
              ],
            )
          ],
        ),
      ),
    );
  }
}
