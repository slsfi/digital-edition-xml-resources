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
	*    XSLT stylesheet: shared-language-functions.xsl
	*
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2026-05-27
	*    Licence: CC BY 4.0 (Attribution 4.0 International),
	*             https://creativecommons.org/licenses/by/4.0/
	*
	*    Changes:
	*        v1.0.0 (2026-05-27)
	*
	*    Description:
	*        This XSLT document defines functions for handling languages
	*        in the `slsFn` namespace
	*        https://www.sls.fi/ns/digitaledition/functions/.
	*
	*    Dependencies:
	*        None.
	*
	******************************************************************* -->


	<!-- * GLOBAL VARIABLES ******************************************* -->
	
	<!-- * Maps ISO 639-1 language codes to language names in English, Swedish and Finnish.
		 * The outer map key is the language code to resolve.
		 * The inner map key is the language in which the name should be returned:
		 * - en: English
		 * - sv: Swedish
		 * - fi: Finnish * -->
	<xsl:variable name="language-names" as="map(xs:string, map(xs:string, xs:string))"
	              select="
	                  map {
	                      'ar': map {
	                          'en': 'Arabic',
	                          'sv': 'arabiska',
	                          'fi': 'arabia'
	                      },
	                      'cs': map {
	                          'en': 'Czech',
	                          'sv': 'tjeckiska',
	                          'fi': 'tšekki'
	                      },
	                      'da': map {
	                          'en': 'Danish',
	                          'sv': 'danska',
	                          'fi': 'tanska'
	                      },
	                      'de': map {
	                          'en': 'German',
	                          'sv': 'tyska',
	                          'fi': 'saksa'
	                      },
	                      'el': map {
	                          'en': 'Greek',
	                          'sv': 'grekiska',
	                          'fi': 'kreikka'
	                      },
	                      'en': map {
	                          'en': 'English',
	                          'sv': 'engelska',
	                          'fi': 'englanti'
	                      },
	                      'es': map {
	                          'en': 'Spanish',
	                          'sv': 'spanska',
	                          'fi': 'espanja'
	                      },
	                      'et': map {
	                          'en': 'Estonian',
	                          'sv': 'estniska',
	                          'fi': 'viro'
	                      },
	                      'fi': map {
	                          'en': 'Finnish',
	                          'sv': 'finska',
	                          'fi': 'suomi'
	                      },
	                      'fr': map {
	                          'en': 'French',
	                          'sv': 'franska',
	                          'fi': 'ranska'
	                      },
	                      'he': map {
	                          'en': 'Hebrew',
	                          'sv': 'hebreiska',
	                          'fi': 'heprea'
	                      },
	                      'hu': map {
	                          'en': 'Hungarian',
	                          'sv': 'ungerska',
	                          'fi': 'unkari'
	                      },
	                      'is': map {
	                          'en': 'Icelandic',
	                          'sv': 'isländska',
	                          'fi': 'islanti'
	                      },
	                      'it': map {
	                          'en': 'Italian',
	                          'sv': 'italienska',
	                          'fi': 'italia'
	                      },
	                      'la': map {
	                          'en': 'Latin',
	                          'sv': 'latin',
	                          'fi': 'latina'
	                      },
	                      'lt': map {
	                          'en': 'Lithuanian',
	                          'sv': 'litauiska',
	                          'fi': 'liettua'
	                      },
	                      'lv': map {
	                          'en': 'Latvian',
	                          'sv': 'lettiska',
	                          'fi': 'latvia'
	                      },
	                      'nl': map {
	                          'en': 'Dutch',
	                          'sv': 'nederländska',
	                          'fi': 'hollanti'
	                      },
	                      'no': map {
	                          'en': 'Norwegian',
	                          'sv': 'norska',
	                          'fi': 'norja'
	                      },
	                      'pl': map {
	                          'en': 'Polish',
	                          'sv': 'polska',
	                          'fi': 'puola'
	                      },
	                      'pt': map {
	                          'en': 'Portuguese',
	                          'sv': 'portugisiska',
	                          'fi': 'portugali'
	                      },
	                      'ru': map {
	                          'en': 'Russian',
	                          'sv': 'ryska',
	                          'fi': 'venäjä'
	                      },
	                      'sv': map {
	                          'en': 'Swedish',
	                          'sv': 'svenska',
	                          'fi': 'ruotsi'
	                      }
	                  }
	              "/>



	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:language-name" as="xs:string?">
	<!-- * Resolves a language code to a language name.
		 * The code parameter is the language code to resolve.
		 * The language parameter controls the language of the returned name.
		 * The language parameter is normalised with slsFn:normalise-language.
		 * For example, sv-FI is treated as sv.
		 * If the code is unsupported, the empty sequence is returned. * -->
		<xsl:param name="code" as="xs:string?"/>
		<xsl:param name="language" as="xs:string?"/>

		<xsl:variable name="normalised-code" as="xs:string"
		              select="substring-before(normalize-space($code) || '-', '-') => lower-case()"/>
		
		<xsl:variable name="lang" as="xs:string"
		              select="slsFn:normalise-language($language)"/>
		
		<xsl:sequence select="if (map:contains($language-names, $normalised-code))
		                          then $language-names($normalised-code)($lang)
		                      else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:normalise-language" as="xs:string">
		<!-- * Returns a supported language code for date formatting.
			 * The language is normalised from a possibly longer language tag,
			 * for example sv-FI, en-GB or fi-FI.
			 * If the language is empty, sv is returned. * -->
		<xsl:param name="language" as="xs:string?"/>
		
		<xsl:variable name="norm-lang" as="xs:string"
		              select="substring-before(normalize-space($language) || '-', '-')
		                      => lower-case()"/>
		
		<xsl:sequence select="if (not(normalize-space($norm-lang)))
			                      then 'sv'
			                  else $norm-lang"/>
	</xsl:function>


</xsl:stylesheet>