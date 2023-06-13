package com.springboot.MyTodoList.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.ReplyKeyboardRemove;

public class BotHelper {

	private static final Logger logger = LoggerFactory.getLogger(BotHelper.class);

	public static void sendMessageToTelegram(Long chatId, String text, TelegramLongPollingBot bot) {

		try {
			// prepare message
			SendMessage messageToTelegram = new SendMessage();
			messageToTelegram.setChatId(chatId);
			messageToTelegram.setText(text);

			// hide keyboard
			ReplyKeyboardRemove keyboardMarkup = new ReplyKeyboardRemove(true);
			messageToTelegram.setReplyMarkup(keyboardMarkup);

			// send message
			bot.execute(messageToTelegram);

		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
	}

}
