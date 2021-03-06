﻿<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="f:f"
	version="2.0">
	<xsl:output method="xhtml" encoding="UTF-8" media-type="text/html" indent="yes" omit-xml-declaration="yes"/>

	<!-- Перевод XSL даты в миллисекунды -->
	<xsl:function name="f:date_to_millis">
		<xsl:param name="date" as="xs:date"/>
		<xsl:sequence select="($date - xs:date('1970-01-01')) div xs:dayTimeDuration('PT0.001S')"/>
	</xsl:function>

	<!-- Перевод миллисекунд в XSL дату -->
	<xsl:function name="f:millis_to_date" as="xs:date">
		<xsl:param name="millis"/>
		<xsl:sequence select="if ($millis) then xs:date('1970-01-01') + $millis * xs:dayTimeDuration('PT0.001S') else xs:date('1970-01-01')"/>
	</xsl:function>

	<!-- Перевод даты из CMS вида (23.11.2017) в XSL вид -->
	<xsl:function name="f:xsl_date" as="xs:date">
		<xsl:param name="str_date"/>
		<xsl:variable name="parts" select="tokenize(tokenize($str_date, '\s+')[1], '\.')"/>
		<xsl:sequence select="if ($parts[3]) then xs:date(concat($parts[3], '-', $parts[2], '-', $parts[1])) else xs:date('1970-01-01')"/>
	</xsl:function>

	<!-- Перевод даты из XSL вида в CMS вид (23.11.2017) -->
	<xsl:function name="f:format_date">
		<xsl:param name="date" as="xs:date"/>
		<xsl:sequence select="format-date($date, '[D01].[M01].[Y0001]')"/>
	</xsl:function>

	<!-- Перевод строки в число. Пуская строка переводится в 0 -->
	<xsl:function name="f:num">
		<xsl:param name="num_str"/>
		<xsl:value-of select="if (not($num_str) or $num_str = '') then 0 else number(translate(translate($num_str, '&#160;', ''), ',', '.'))"/>
	</xsl:function>

	<!-- Выбирает нужную форму слова в зависимости от заданного числа. Формы слова - массив -->
	<xsl:function name="f:ending" as="xs:string">
		<xsl:param name="number_str"  />
		<xsl:param name="words" />
		<xsl:variable name="number" select="round(number($number_str))"/>
		<xsl:variable name="mod100" select="$number mod 100" />
		<xsl:variable name="mod10" select="$number mod 10" />
		<xsl:value-of select="if ($mod100 &gt; 10 and $mod100 &lt; 20) then $words[3]
					     else if ($mod10 = 1) then $words[1]
					     else if ($mod10 &gt; 0 and $mod10 &lt; 5) then $words[2]
					     else $words[3]" />
	</xsl:function>

	<!-- Перевод даты из CMS формата в запись число-месяц вида 15 февраля -->
	<xsl:function name="f:day_month_string" as="xs:string">
		<xsl:param name="date" as="xs:string" />
		<xsl:variable name="parts" select="tokenize(tokenize($date, '\s+')[1], '\.')"/>
		<xsl:variable name="month" select="number($parts[2])"/>
		<xsl:variable name="months" select="('января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря')"/>
		<xsl:value-of select="concat(number($parts[1]), ' ', $months[$month], ' ', $parts[3])"/>
	</xsl:function>

	<!-- Перевод даты из CMS формата в запись число-месяц вида 15фев -->
	<xsl:function name="f:day_month_short_string" as="xs:string">
		<xsl:param name="date" as="xs:string" />
		<xsl:variable name="parts" select="tokenize(tokenize($date, '\s+')[1], '\.')"/>
		<xsl:variable name="month" select="number($parts[2])"/>
		<xsl:variable name="months" select="('янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек')"/>
		<xsl:value-of select="concat(number($parts[1]), $months[$month])"/>
	</xsl:function>

	<!-- Перевод даты из XSL формата в запись число-месяц-год вида 15 февраля 2018 -->
	<xsl:function name="f:day_month_year" as="xs:string">
		<xsl:param name="date" as="xs:date" />
		<xsl:variable name="months" select="('января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря')"/>
		<xsl:value-of select="concat(day-from-date($date), ' ', $months[month-from-date($date)], ' ', year-from-date($date))"/>
	</xsl:function>

	<!-- 
	Для того чтобы выбрать нужный option, у селекта устанавливается атрибут value.
	После загрузки страницы это значение jquery устанавливает в селект
	 -->
	<xsl:template name="SELECT_SCRIPT">
	$(document).ready(function() {
		$('select[value]').each(function() {
			var value = $(this).attr('value');
			if (value != '')
				$(this).val(value);
		});
	});
	</xsl:template>

	<!-- ****************************    Добавление параметра к ссылке    ******************************** -->
	
	<!-- Усановка параметра, если его нет, или замена значения параметра (в том числе удаление) -->
	<xsl:function name="f:set_url_param" as="xs:string">
		<xsl:param name="url" as="xs:string"/>
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="value"/>
		<xsl:variable name="val_enc" select="encode-for-uri(string($value))"/>
		<xsl:value-of 
			select="if (not($val_enc) or $val_enc = '') then replace(replace($url, concat('(\?|&amp;)', $name, '=', '.*?($|&amp;)'), '$1'), '&amp;$|\?$', '')
					else if (contains($url, concat($name, '='))) then replace($url, concat($name, '=', '.*?($|&amp;)'), concat($name, '=', $value, '$1'))
					else if (contains($url, '?')) then concat($url, '&amp;', $name, '=', $val_enc)
					else concat($url, '?', $name, '=', $val_enc)"/>
	</xsl:function>
	
	<!-- Добавление параметра, даже если такой параметр уже есть (множественные значения) -->
	<xsl:function name="f:add_url_param" as="xs:string">
		<xsl:param name="url" as="xs:string"/>
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="value"/>
		<xsl:variable name="val_enc" select="encode-for-uri($value)"/>
		<xsl:value-of 
			select="if (contains($url, '?')) then concat($url, '&amp;', $name, '=', $val_enc)
					else concat($url, '?', $name, '=', $val_enc)"/>
	</xsl:function>

	<!-- Удаление параметра с определенным значением -->
	<xsl:function name="f:remove_url_param" as="xs:string">
		<xsl:param name="url" as="xs:string"/>
		<xsl:param name="name" as="xs:string"/>
		<xsl:param name="value"/>
		<xsl:variable name="val_enc" select="replace(encode-for-uri($value), '%20', '\\+')"/>
<!-- 		<xsl:variable name="start" select="substring-before($url, concat($name, '=', $val_enc))"/> -->
<!-- 		<xsl:variable name="end_b" select="substring-after($url, concat($name, '=', $val_enc))"/> -->
<!-- 		<xsl:variable name="end" select="if (starts-with($end_b, '&amp;')) then substring-after($end_b, '&amp;') else $end_b"/> -->
<!-- 		<xsl:value-of select="$url"/> -->
		<!--
		<xsl:value-of select="if (string-length($start) = 0) then $start else concat($start, $end)"/>
		-->
		<xsl:value-of 
			select="replace(replace($url, concat('(\?|&amp;)', $name, '=', $val_enc, '($|&amp;)'), '$1'), '&amp;$|\?$', '')"/>
	</xsl:function>

	<!-- Вставка переменной в ссылку (добавление как query string). match соответствует ссылке -->
	<xsl:template match="*" mode="querystr_var">
		<xsl:param name="name"/>
		<xsl:param name="value"/>
		<xsl:if test="contains(., '?')">
			<xsl:value-of select="."/>&amp;<xsl:value-of select="$name"/>=<xsl:value-of select="$value"/>
		</xsl:if>
		<xsl:if test="not(contains(., '?'))">
			<xsl:value-of select="."/>?<xsl:value-of select="$name"/>=<xsl:value-of select="$value"/>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>