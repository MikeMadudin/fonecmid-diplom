
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
		
#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	ПроверитьДоговор(Отказ);

	СформироватьДвижения();

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;		
	КонецЕсли;
	
	Если ЭтоНовый() Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							"Создан новый документ ""Обслуживание клиента"".
							|Описание проблемы: %1.
							|Дата проведения работ: %2.
							|Время начала работ (план): %3.
							|Время окончания работ (план): %4.
							|Клиент: %5.
							|Специалист: %6.",
							ОписаниеПроблемы,
							Формат(ДатаПроведенияРабот, "ДФ=dd.MM.yyyy;"),
							Формат(ВремяНачалаРабот, "ДЛФ=T;"),
							Формат(ВремяОкончанияРабот, "ДЛФ=T;"),
							Клиент,
							Специалист);
		ВКМ_ОбщегоНазначенияСервер.ЗаписатьУведомлениеВСправочник(ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПроверитьДоговор(Отказ)

	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ОбслуживаниеКлиента.Ссылка
		|ИЗ
		|	Документ.ВКМ_ОбслуживаниеКлиента КАК ВКМ_ОбслуживаниеКлиента
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|		ПО ВКМ_ОбслуживаниеКлиента.Договор = ДоговорыКонтрагентов.Ссылка
		|ГДЕ
		|	ДоговорыКонтрагентов.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание)
		|	И ВКМ_ОбслуживаниеКлиента.Ссылка = &Ссылка
		|	И ВКМ_ОбслуживаниеКлиента.Дата
		|		МЕЖДУ ДоговорыКонтрагентов.ВКМ_ПериодДействияНачало И ДоговорыКонтрагентов.ВКМ_ПериодДействияКонец";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		ТекстСообщения = "Ошибка проведения документа!
						|В договоре выбран неверный вид договора,
						|либо дата документа лежит ВНЕ диапазона дат действия договора.";
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , , Отказ);
	КонецЕсли;
КонецПроцедуры

Процедура СформироватьДвижения()

	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.ОписаниеРабот,
		|	ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.ЧасыКОплатеКлиенту КАК КоличествоЧасов,
		|	ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.ЧасыКОплатеКлиенту * ЕСТЬNULL(ДоговорыКонтрагентов.ВКМ_СтоимостьЧасаРаботы,
		|		0) КАК СуммаКОплате
		|ИЗ
		|	Документ.ВКМ_ОбслуживаниеКлиента.ВыполненныеРаботы КАК ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|		ПО ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.Ссылка.Договор = ДоговорыКонтрагентов.Ссылка
		|ГДЕ
		|	ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина;
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_ВыполненныеКлиентуРаботы.Добавить();
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.Договор = Договор;
		Движение.КоличествоЧасов = Выборка.КоличествоЧасов;
		Движение.СуммаКОплате = Выборка.СуммаКОплате;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли