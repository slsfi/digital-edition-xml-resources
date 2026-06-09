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
	*    XSLT stylesheet: shared-functions.xsl
	*
	*    Version: 1.3.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-03-07
	*    Licence: CC BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.3.0 (2026-06-09)
	*             - Add norm-or-empty() and get-witnesses().
	*        v1.2.0 (2026-04-16)
	*             - Add 'illegible' to values handled by get-reason-text().
	*        v1.1.2 (2025-11-19)
	*             - Fix decode-uri-encoded-colons().
	*        v1.1.1 (2025-09-11)
	*             - Fix get-form-shift-classname().
	*        v1.1.0 (2025-09-11)
	*             - Add get-hand-medium(), get-text-elem-hand-medium(),
	*               is-same-medium-type() and get-form-shift-classname().
	*        v1.0.0 (2025-03-07)
	*
	*    Description:
	*        This XSLT document defines common functions in the `slsFn`
	*        namespace https://www.sls.fi/ns/digitaledition/functions/.
	*
	*    Dependencies:
	*        The `required-global-variables.xsl` must be imported before
	*        this stylesheet.
	*
	******************************************************************* -->


	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:get-heading-level" as="xs:integer">
	<!-- * Determines the heading level of the given context item.
	     * Counts the number of ancestor <div> or <body> elements that
	     * contain a <head> child element.
	     * Calls the overloaded function with an offset of 0. * -->
		<xsl:param name="context-item" as="node()"/>

		<xsl:sequence select="slsFn:get-heading-level($context-item, 0)"/>
	</xsl:function>

	<xsl:function name="slsFn:get-heading-level" as="xs:integer">
	<!-- * Determines the heading level of the given context item, 
         * with an optional offset adjustment.
         * Counts the number of ancestor <div> or <body> elements that 
         * contain a <head> child element, then applies the offset. Ensures
         * the offset is only added if it is greater than zero. * -->
		<xsl:param name="context-item" as="node()"/>
		<xsl:param name="offset" as="xs:integer"/>

		<xsl:sequence select="count($context-item/ancestor::tei:div[tei:head] |
		                            $context-item/ancestor::tei:body[tei:head]
		                            ) + (if ($offset gt 0) then $offset else 0)"/>
	</xsl:function>


	<xsl:function name="slsFn:format-date-or-year" as="xs:string?" cache="yes">
	<!-- * Formats a date or year value into a human-readable string.
	     * If the input is a valid date, it is formatted as "D/M Y".
	     * If the input is a valid year, it is returned as a string.
	     * Otherwise, it returns an empty sequence. * -->
		<xsl:param name="date-or-year" as="xs:string?"/>

		<xsl:sequence select="
			if ($date-or-year castable as xs:date)
			    then format-date(xs:date($date-or-year), '[D]/[M] [Y]')
			else if ($date-or-year castable as xs:gYear)
			    then string(xs:gYear($date-or-year))
			else ()
		"/>
	</xsl:function>


	<xsl:function name="slsFn:decode-uri-encoded-colons" as="xs:string?"
	              cache="yes">
	<!-- * Decodes URI-encoded colons ("%3A") in a string by replacing them
	     * with ":".
	     * Returns the modified string or an empty sequence if input is
	     * empty. * -->
		<xsl:param name="text" as="xs:string?"/>

		<xsl:sequence select="replace($text, '%3A', ':')"/>
	</xsl:function>
	
	
	<xsl:function name="slsFn:norm-or-empty" as="xs:string?">
	<!-- * Return the input text with normalized space. If the input text
	     * is the empty sequence or whitespace-only, the function returns
	     * the empty sequence. -->
		<xsl:param name="text" as="xs:string?"/>
		
		<xsl:sequence select="
			if (exists($text))
			    then let $norm-text := normalize-space($text)
			         return
			             if (boolean($norm-text))
			                 then $norm-text
			             else ()
			else ()
		"/>
	</xsl:function>


	<xsl:function name="slsFn:get-reason-text" as="xs:string?" cache="yes">
	<!-- * Converts a given reason code into a human-readable explanation
	     * in Swedish. The function maps predefined reason codes (e.g.,
	     * "writing", "binding", "damage") to corresponding descriptions.
	     * If the reason is not recognized, it returns an empty sequence. * -->
		<xsl:param name="reason" as="xs:string?"/>

		<xsl:sequence
			select="if ($reason eq 'writing' or $reason eq 'illegible' or not($reason))
			            then 'handstil eller innehåll'
			        else if ($reason eq 'binding')
			            then 'inbindning/konservering'
			        else if ($reason eq 'damage')
			            then 'skada'
			        else if ($reason eq 'endline')
		                then 'radslut'
			        else if ($reason eq 'erased')
			            then 'utsuddning'
			        else if ($reason eq 'faded')
			            then 'svagt bläck'
			        else if ($reason eq 'glue')
			            then 'överlimning eller tejp'
			        else if ($reason eq 'inksmudge')
			            then 'bläckplump eller motsvarande'
			        else if ($reason eq 'overstrike')
			            then 'strykning'
			        else if ($reason eq 'overtyped')
			            then 'strykning på skrivmaskin'
			        else if ($reason eq 'overwritten')
			            then 'överskrivning'
			        else if ($reason eq 'ribbon')
			            then 'dåligt färgband i skrivmaskin'
			        else if ($reason eq 'seal')
			            then 'sigill'
			        else if ($reason eq 'stamp')
			            then 'frimärke'
			        else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:get-gap-space-est-content" as="item()*" cache="yes">
	<!-- * Generates placeholder content for unreadable or missing text.
	     * The placeholder is based on the type ("gap" or "space"), unit
	     * ("chars", "words", "lines"), and quantity specified.
	     * Uses dashes for gaps and non-breaking spaces (NBSP) for spaces. * -->
		<xsl:param name="type" as="xs:string"/>
		<xsl:param name="unit" as="xs:string"/>
		<xsl:param name="quantity" as="xs:integer"/>

		<xsl:variable name="repeat-text" as="xs:string">
			<xsl:choose>
				<xsl:when test="$type eq 'gap'">
					<xsl:text>{
						if ($unit eq 'chars')
						    then '-'
						else if ($unit eq 'words')
						    then '----'
						else '---- ---- ---- ---- ----'
					}</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>{
						if ($unit eq 'chars')
						    then $NBSP
						else if ($unit eq 'words')
						    then slsFn:repeat-string($NBSP, 4)
						else slsFn:repeat-string($NBSP, 24)
					}</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="br-element" as="element(br)">
			<xsl:element name="br"/>
		</xsl:variable>

		<xsl:sequence select="
			if ($unit eq 'chars')
			    then slsFn:repeat-string($repeat-text, $quantity)
			else if ($unit eq 'words')
			    then slsFn:repeat-string($repeat-text, $quantity, ' ')
			else slsFn:repeat-string($repeat-text, $quantity, $br-element)
		"/>
	</xsl:function>


	<xsl:function name="slsFn:repeat-string" as="item()*" cache="yes">
	<!-- * Repeats a given string a specified number of times without
	     * a separator. * -->
		<xsl:param name="str" as="xs:string"/>
		<xsl:param name="count" as="xs:integer"/>

		<xsl:sequence select="slsFn:repeat-string($str, $count, '')"/>
	</xsl:function>

	<xsl:function name="slsFn:repeat-string" as="item()*" cache="yes">
	<!-- * Repeats a given string a specified number of times with a separator.
	     * The separator can be a string or an XML element.
	     * If the separator is a string, the repeated strings are joined by it.
	     * If the separator is an element, it is inserted between each
	     * repetition. * -->
		<xsl:param name="str" as="xs:string"/>
		<xsl:param name="count" as="xs:integer"/>
		<xsl:param name="separator" as="item()?"/>

		<xsl:choose>
			<xsl:when test="$separator instance of xs:string">
				<xsl:sequence select="
					string-join((for $i in 1 to $count return $str), $separator)
				"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="
					for $i in 1 to $count
				    return ($str, if ($i lt $count) then $separator else ())
				"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xsl:function name="slsFn:get-gap-space-extent-text" as="xs:string"
	              cache="yes">
	<!-- * Generates a textual description in Swedish of the extent of a gap
	     * or space. Unit refers to characters (chars), words, or lines. * -->
		<xsl:param name="unit" as="xs:string"/>
		<xsl:param name="quantity" as="xs:integer"/>

		<xsl:variable name="unit-text" select="if ($unit eq 'chars')
		                                           then 'tecken'
		                                       else if ($unit eq 'words')
		                                           then 'ord'
		                                       else if ($quantity gt 1)
		                                           then 'rader'
		                                       else 'rad'"/>
		<xsl:sequence select="$quantity || ' ' || $unit-text"/>
	</xsl:function>


	<xsl:function name="slsFn:get-hand-medium" as="xs:string?">
	<!-- * Look up the @medium corresponding to the @hand value of the
	     * $context-item, which must be an element (of any type).
	     * Relies on the prebuilt $hand-medium-by-id map for the lookup. * -->
		<xsl:param name="context-item" as="element(*)"/>

		<xsl:variable name="id" select="substring-after($context-item/@hand, '#')"/>
		<xsl:sequence select="if ($id)
			                      then map:get($hand-medium-by-id, $id)
			                  else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:get-text-elem-hand-medium" as="xs:string">
	<!-- * Look up the @medium corresponding to the @hand value of the
	     * tei:text element. $context-item is any node in the same
		 * document (used to anchor the search). If @hand is not set on
	     * the tei:text element, it is assumed to be of medium 'black-ink',
	     * which is then returned. * -->
		<xsl:param name="context-item" as="node()"/>

		<xsl:variable name="text-hand"
			select="root($context-item)/tei:TEI/tei:text/@hand"/>
		<xsl:variable name="text-id"
			select="substring-after($text-hand, '#')"/>
		<xsl:sequence select="
			if ($text-id)
			    then map:get($hand-medium-by-id, $text-id)
			else $default-medium
		"/>
	</xsl:function>


	<xsl:function name="slsFn:is-same-medium-type" as="xs:boolean">
	<!-- * Given two @medium values, returns true if they belong to
	     * the same type of medium, and false otherwise. Medium values
	     * 'print', 'stamp' and 'typescript' are considered to be of
	     * the same type (“printlike”), and all other values of the
	     * same type (“handwritinglike”). * -->
		<xsl:param name="medium1" as="xs:string?"/>
		<xsl:param name="medium2" as="xs:string?"/>
		
		<xsl:variable name="printlike-mediums" select="('print',
			                                            'stamp',
			                                            'typescript')"/>
		<xsl:sequence select="($medium1 = $printlike-mediums) eq
			                  ($medium2 = $printlike-mediums)"/>
	</xsl:function>


	<xsl:function name="slsFn:get-form-shift-classname" as="xs:string?">
	<!-- * Given a $context-item, which can be an element of any type,
	     * returns the string 'form-shift' if the element has such a @hand
	     * that it involves a form-shift (“printlike” <-> “handwritinglike”)
	     * that should be rendered, otherwise an empty sequence is returned. -->
		<xsl:param name="context-item" as="element(*)"/>
		
		<xsl:variable name="elem-medium"
		              select="slsFn:get-hand-medium($context-item)"/>
		<xsl:variable name="text-medium"
		              select="slsFn:get-text-elem-hand-medium($context-item)"/>
		<xsl:sequence select="if (empty($elem-medium) or slsFn:is-same-medium-type($elem-medium, $text-medium))
		                          then ()
		                      else 'form-shift'"/>
	</xsl:function>


	<xsl:function name="slsFn:get-witnesses" as="element(tei:witness)*">
	<!-- * Return the tei:witness elements with @xml:id values corresponding
		 * to the @wit value of the $context-item. $context-item is typically
		 * a tei:lem or tei:rdg element. * -->
		<xsl:param name="context-item" as="element(*)?"/>
		
		<xsl:variable name="wit-refs" as="xs:string*"
			          select="normalize-space($context-item/@wit) => tokenize()"/>

		<xsl:sequence select="root($context-item)/tei:TEI/tei:teiHeader/tei:fileDesc
			                  /tei:sourceDesc/tei:listWit
			                  /tei:witness[('#' || @xml:id) = $wit-refs]"/>
	</xsl:function>

</xsl:stylesheet>