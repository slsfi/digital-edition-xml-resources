<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: shared-date-functions.xsl
	*
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2026-05-19
	*    Licence: CC-BY 4.0 (Attribution 4.0 International),
	*             https://creativecommons.org/licenses/by/4.0/
	*
	*    Changes:
	*        v1.0.0 (2026-05-19)
	*
	*    Description:
	*        This XSLT document defines functions for handling dates in the
	*        `slsFn` namespace
	*        https://www.sls.fi/ns/digitaledition/functions/.
	*
	*    Dependencies:
	*        None.
	*
	******************************************************************* -->


	<!-- * GLOBAL VARIABLES ******************************************* -->
	
	<xsl:variable name="month-names" static="yes"
		          as="map(xs:string, map(xs:string, array(xs:string)))"
	              select="
	              map {
	                  'en': map {
	                      'full': [
	                          'January', 'February', 'March', 'April',
	                          'May', 'June', 'July', 'August',
	                          'September', 'October', 'November', 'December'
	                      ],
	                      'abbr': [
	                          'Jan', 'Feb', 'Mar', 'Apr',
	                          'May', 'Jun', 'Jul', 'Aug',
	                          'Sept', 'Oct', 'Nov', 'Dec'
	                      ]
	                  },
	                  'sv': map {
	                      'full': [
	                          'januari', 'februari', 'mars', 'april',
	                          'maj', 'juni', 'juli', 'augusti',
	                          'september', 'oktober', 'november', 'december'
	                      ],
	                      'abbr': [
	                          'jan', 'feb', 'mars', 'apr',
	                          'maj', 'juni', 'juli', 'aug',
	                          'sep', 'okt', 'nov', 'dec'
	                      ]
	                      },
	                  'fi': map {
	                      'full': [
	                          'tammikuu', 'helmikuu', 'maaliskuu', 'huhtikuu',
	                          'toukokuu', 'kesäkuu', 'heinäkuu', 'elokuu',
	                          'syyskuu', 'lokakuu', 'marraskuu', 'joulukuu'
	                      ],
	                      'abbr': [
	                          'tammi', 'helmi', 'maalis', 'huhti',
	                          'touko', 'kesä', 'heinä', 'elo',
	                          'syys', 'loka', 'marras', 'joulu'
	                      ]
	                  }
	              }
	              "/>

	
	
	<!-- * FUNCTIONS ************************************************** -->
	
	<xsl:function name="slsFn:month-name" as="xs:string?">
		<!-- * Returns the localised name of a month.
			 * The month parameter must be an integer from 1 to 12.
			 * Supported language parameter values are:
			 * - sv
			 * - fi
			 * - en
			 * If it's not one of these 'sv' will be used.
			 * The form parameter controls whether the full or abbreviated month name
			 * is returned. Supported forms are:
			 * - full: full month name
			 * - abbr: abbreviated month name
			 * If the form is empty or unsupported, full is used.
			 * If the month is outside the range 1 to 12, the empty sequence is returned. * -->
		<xsl:param name="month" as="xs:integer"/>
		<xsl:param name="language" as="xs:string?"/>
		<xsl:param name="form" as="xs:string"/>
		
		<xsl:variable name="lang" as="xs:string"
		              select="if ($language = ('en', 'fi', 'sv'))
		                          then $language
		                      else 'sv'"/>
		
		<xsl:variable name="month-form" as="xs:string"
		              select="if ($form = ('full', 'abbr'))
		                          then $form
		                      else 'full'"/>

		<xsl:sequence select="if ($month ge 1 and $month le 12)
		                          then $month-names($lang)($month-form)?($month)
		                      else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:format-w3c-date" as="xs:string?">
		<!-- * Formats a W3C date into a human-readable, localised string.
			 * Supported W3C Schema date datatypes are:
			 * - xs:date, for example 1876-03-12
			 * - xs:gYear, for example 1876
			 * - xs:gMonth, written as two leading hyphens followed by mm
			 * - xs:gDay, written as three leading hyphens followed by dd
			 * - xs:gYearMonth, for example 1876-03
			 * - xs:gMonthDay, written as two leading hyphens followed by mm-dd
			 * Unsupported dates are returned as the empty sequence.
			 * * Supported language parameter values are:
			 * - sv
			 * - fi
			 * - en
			 * If it's not one of these 'sv' will be used. * -->
		<xsl:param name="date" as="xs:string?"/>
		<xsl:param name="language" as="xs:string?"/>
		
		<xsl:variable name="lang" as="xs:string"
		              select="if ($language = ('en', 'fi', 'sv'))
		                          then $language
		                      else 'sv'"/>
		
		<xsl:variable name="norm-date" as="xs:string?"
		              select="normalize-space($date)"/>
		
		<xsl:sequence select="if (not($norm-date))
		                          then ()
		                      else if ($norm-date castable as xs:date)
		                          then slsFn:format-xs-date(xs:date($norm-date), $lang)
		                      else if ($norm-date castable as xs:gYearMonth)
		                          then slsFn:format-xs-gYearMonth(xs:gYearMonth($norm-date), $lang)
		                      else if ($norm-date castable as xs:gYear)
		                          then string(xs:gYear($norm-date))
		                      else if ($norm-date castable as xs:gMonthDay)
		                          then slsFn:format-xs-gMonthDay(xs:gMonthDay($norm-date), $lang)
		                      else if ($norm-date castable as xs:gMonth)
		                          then slsFn:format-xs-gMonth(xs:gMonth($norm-date), $lang)
		                      else if ($norm-date castable as xs:gDay)
		                          then slsFn:format-xs-gDay(xs:gDay($norm-date), $lang)
		                      else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:format-xs-date" as="xs:string">
		<!-- * Formats an xs:date value as a localised date string.
			 * English dates are formatted with an abbreviated month name,
			 * for example 12 Apr 1885.
			 * Swedish and Finnish dates are formatted numerically,
			 * for example 12.4.1885.
			 * The lang parameter must be a supported normalised language code. * -->
		<xsl:param name="date" as="xs:date"/>
		<xsl:param name="lang" as="xs:string"/>
		
		<xsl:variable name="year" as="xs:string"
		              select="format-integer(year-from-date($date), '0001')"/>
		<xsl:variable name="month" as="xs:integer"
		              select="month-from-date($date)"/>
		<xsl:variable name="day" as="xs:integer"
		              select="day-from-date($date)"/>
		
		<xsl:sequence select="if ($lang eq 'en')
		                          then string-join((
		                                   string($day),
		                                   slsFn:month-name($month, $lang, 'abbr'),
		                                   $year
		                               ), ' ')
		                      else
		                          string-join((
		                              string($day),
		                              string($month),
		                              $year
		                          ), '.')"/>
	</xsl:function>


	<xsl:function name="slsFn:format-xs-gYearMonth" as="xs:string">
		<!-- * Formats an xs:gYearMonth value as a localised month and year string.
			 * The month is written as a full month name in the selected language,
			 * followed by the year.
			 * Example outputs are:
			 * - April 1885
			 * - april 1885
			 * - huhtikuu 1885
			 * The lang parameter must be a supported normalised language code. * -->
		<xsl:param name="date" as="xs:gYearMonth"/>
		<xsl:param name="lang" as="xs:string"/>
		
		<xsl:variable name="date-string" as="xs:string"
		              select="string($date)"/>
		<xsl:variable name="year" as="xs:string"
		              select="substring($date-string, 1, 4)"/>
		<xsl:variable name="month" as="xs:integer"
		              select="xs:integer(substring($date-string, 6, 2))"/>
		
		<xsl:sequence select="string-join((
		                          slsFn:month-name($month, $lang, 'full'),
		                          $year
		                      ), ' ')"/>
	</xsl:function>


	<xsl:function name="slsFn:format-xs-gMonthDay" as="xs:string">
		<!-- * Formats an xs:gMonthDay value as a localised day and month string.
			 * The month is written as a full month name in the selected language.
			 * Example outputs are:
			 * - 12 April
			 * - 12 april
			 * - 12. huhtikuuta
			 * The lang parameter must be a supported normalised language code. * -->
		<xsl:param name="date" as="xs:gMonthDay"/>
		<xsl:param name="lang" as="xs:string"/>
		
		<xsl:variable name="date-string" as="xs:string"
		              select="string($date)"/>
		<xsl:variable name="month" as="xs:integer"
		              select="xs:integer(substring($date-string, 3, 2))"/>
		<xsl:variable name="day" as="xs:integer"
		              select="xs:integer(substring($date-string, 6, 2))"/>
		
		<xsl:sequence select="if ($lang eq 'fi')
			                      then string-join((
		                                   string($day) || '.',
		                                   slsFn:month-name($month, $lang, 'full') || 'ta'
		                               ), ' ')
		                      else string-join((
		                               string($day),
		                               slsFn:month-name($month, $lang, 'full')
		                           ), ' ')"/>
	</xsl:function>


	<xsl:function name="slsFn:format-xs-gMonth" as="xs:string">
		<!-- * Formats an xs:gMonth value as a localised month string.
			 * The month is written as a full month name in the selected language.
			 * Example outputs are:
			 * - April
			 * - april
			 * - huhtikuu
			* The lang parameter must be a supported normalised language code. * -->
		<xsl:param name="date" as="xs:gMonth"/>
		<xsl:param name="lang" as="xs:string"/>
		
		<xsl:variable name="month" as="xs:integer"
		              select="xs:integer(substring(string($date), 3, 2))"/>
		
		<xsl:sequence select="slsFn:month-name($month, $lang, 'full')"/>
	</xsl:function>


	<xsl:function name="slsFn:format-xs-gDay" as="xs:string">
		<!-- * Formats an xs:gDay value as a day number without leading zeroes.
			 * Example outputs are:
			 * - 1
			 * - 12
			 * - 31
			 * The lang parameter is accepted for API consistency but is not used. * -->
		<xsl:param name="date" as="xs:gDay"/>
		<xsl:param name="lang" as="xs:string"/>
		
		<xsl:sequence select="string(xs:integer(substring(string($date), 4, 2)))"/>
	</xsl:function>


</xsl:stylesheet>