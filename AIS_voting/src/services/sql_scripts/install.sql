ALTER TABLE public._meeting DROP CONSTRAINT _meeting_agenda_id_key;
ALTER TABLE public._meeting DROP CONSTRAINT _meeting_group_id_key;


ALTER TABLE public._meetingsession ADD CONSTRAINT _meetingsession_meeting_id_fkey FOREIGN KEY (meetingid) REFERENCES _meeting(id) ON DELETE SET NULL;
ALTER TABLE public._questionsession ADD CONSTRAINT _questionsession_meeting_id_fkey FOREIGN KEY (questionid) REFERENCES _question(id) ON DELETE SET NULL;
ALTER TABLE public._questionsession ADD CONSTRAINT _questionsession_voting_mode_id_fkey FOREIGN KEY (votingmodeid) REFERENCES _votingmode(id) ON DELETE SET NULL;
ALTER TABLE public._result ADD CONSTRAINT _result_questionsession_id_fkey FOREIGN KEY (questionsessionid) REFERENCES _questionsession (id) ON DELETE SET NULL;
ALTER TABLE public._result ADD CONSTRAINT _result_user_mode_id_fkey FOREIGN KEY (userid) REFERENCES _user(id) ON DELETE SET NULL;


-- INSERT DEFAULT DATA
INSERT INTO public._votingmode (name, defaultdecision, ordernum, includeddecisions)
    VALUES ('Принять', 'Большинство от установленного числа', 0, 'Большинство от установленного числа;2/3 от установленного числа;1/3 от установленного числа;Большинство от выбранных членов;2/3 от выбранных членов;1/3 от выбранных членов;Большинство от зарегистрированных членов;2/3 от зарегистрированных членов;1/3 от зарегистрированных членов;');
INSERT INTO public._votingmode (name, defaultdecision, ordernum, includeddecisions)
    VALUES ('Отклонить', 'Большинство от установленного числа', 1, 'Большинство от установленного числа;2/3 от установленного числа;1/3 от установленного числа;Большинство от выбранных членов;2/3 от выбранных членов;1/3 от выбранных членов;Большинство от зарегистрированных членов;2/3 от зарегистрированных членов;1/3 от зарегистрированных членов;');
INSERT INTO public._settings (pallettesettings, operatorschemesettings, managerschemesettings, votingsettings, storeboardsettings, soundsettings)
    VALUES ('{"backgroundColor":4288585374,"schemeBackgroundColor":1040187391,"cellColor":520093696,"cellTextColor":4278190080,"cellBorderColor":2315255808,"unRegistredColor":4294967295,"registredColor":4280391411,"voteYesColor":4284084398,"voteNoColor":4294937216,"voteIndifferentColor":4293935355,"askWordColor":4294961979,"onSpeechColor":4289961435,"buttonTextColor":4294967295,"iconOnlineColor":4283215696,"iconOfflineColor":4294198070,"iconDocumentsDownloadedColor":4283215696,"iconDocumentsNotDownloadedColor":4294198070}', 
'{"inverseScheme":false,"cellWidth":200,"cellBorder":1,"cellInnerPadding":10,"cellOuterPadding":10,"isShortNamesUsed":false,"cellTextSize":14,"overflowOption":"Растягивать ячейку по высоте текста","textMaxLines":3,"showOverflow":true,"iconSize":22}',
'{"inverseScheme":false,"cellWidth":200,"cellBorder":1,"cellInnerPadding":10,"cellOuterPadding":10,"isShortNamesUsed":false,"cellTextSize":14,"overflowOption":"Растягивать ячейку по высоте текста","textMaxLines":3,"showOverflow":true}',
            '{"defaultRegistrationInterval":300,"defaultVotingInterval":300,"defaultNewQuestionName":"Доп. вопрос","defaultVotingModeId":null}',
            '{"backgroundColor":4278190080,"textColor":4294967295,"height":300,"width":440,"padding":10,"questionDescriptionFontSize":12,"questionDescriptionMaxLinesOnDiscus":13,"questionDescriptionMaxLinesOnVoting":9,"userCountFontSize":18,"captionFontSize":16,"decisionFontSize":24,"resultsFontSize":24,"timersFontSize":24,"detailsAnimationDuration":3, "detailsRowsCount":10,"detailsFontSize":18}',
            '{"registrationStart":"","registrationEnd":"","votingStart":"","votingEnd":"","defaultStreamUrl":""}')
