<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<xsl:function name="slsFn:get-heading-level" as="xs:integer">
	<!-- * Get the current heading level from the passed context item
	       by calculating the number of ancestor <div> or <body>
	       elements with <head> children. -->
		<xsl:param name="context-item" as="node()"/>
		<xsl:sequence select="slsFn:get-heading-level($context-item, 0)"/>
	</xsl:function>

	<xsl:function name="slsFn:get-heading-level" as="xs:integer">
	<!-- * Get the current heading level from the passed context item
	       by calculating the number of ancestor <div> or <body>
	       elements with <head> children. The result is offset by the
	       passed offset amount. -->
		<xsl:param name="context-item" as="node()"/>
		<xsl:param name="offset" as="xs:integer"/>
		<xsl:sequence select="count($context-item/ancestor::tei:div[tei:head] |
		                            $context-item/ancestor::tei:body[tei:head]
		                            ) + (if ($offset gt 0) then $offset else 0)"/>
	</xsl:function>


	<xsl:function name="slsFn:format-date-or-year" as="xs:string?" cache="yes">
		<xsl:param name="date-or-year" as="xs:string?"/>
		<xsl:sequence select="if ($date-or-year castable as xs:date)
		                      then format-date(xs:date($date-or-year), '[D]/[M] [Y]')
		                      else if ($date-or-year castable as xs:gYear)
		                      then string(xs:gYear($date-or-year))
		                      else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:decode-uri-encoded-colons" as="xs:string?" cache="yes">
		<xsl:param name="text" as="xs:string?"/>
		<xsl:sequence select="translate($text, '%3A', ':')"/>
	</xsl:function>


	<xsl:function name="slsFn:get-reason-text" as="xs:string?" cache="yes">
		<xsl:param name="reason" as="xs:string?"/>
		<xsl:sequence
			select="if ($reason eq 'writing' or not($reason))
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
		<!-- type is either 'gap' or 'space', returns a sequence -->
		<xsl:param name="type" as="xs:string"/>
		<xsl:param name="unit" as="xs:string"/>
		<xsl:param name="quantity" as="xs:integer"/>

		<xsl:variable name="repeat-text" as="xs:string">
			<xsl:choose>
				<xsl:when test="$type eq 'gap'">
					<xsl:text>{
						if ($unit eq 'chars') then '-'
						else if ($unit eq 'words') then '----'
						else '---- ---- ---- ---- ----'
					}</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>{
						if ($unit eq 'chars') then '&#160;'
						else if ($unit eq 'words') then '&#160;&#160;&#160;&#160;'
						else '&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;'
					}</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="br-element">
			<xsl:element name="br"/>
		</xsl:variable>

		<xsl:sequence select="if ($unit eq 'chars')
		                      then slsFn:repeat-string($repeat-text, $quantity)
		                      else if ($unit eq 'words')
		                      then slsFn:repeat-string($repeat-text, $quantity, ' ')
		                      else slsFn:repeat-string($repeat-text, $quantity, $br-element)"/>
	</xsl:function>


	<xsl:function name="slsFn:repeat-string" as="item()*" cache="yes">
		<xsl:param name="str" as="xs:string"/>
		<xsl:param name="count" as="xs:integer"/>

		<xsl:sequence select="slsFn:repeat-string($str, $count, '')"/>
	</xsl:function>

	<xsl:function name="slsFn:repeat-string" as="item()*" cache="yes">
	<!-- Returns a sequence, separator can be a string or an element -->
		<xsl:param name="str" as="xs:string"/>
		<xsl:param name="count" as="xs:integer"/>
		<xsl:param name="separator" as="item()?"/>

		<xsl:choose>
			<xsl:when test="$separator instance of xs:string">
				<xsl:sequence select="string-join((for $i in 1 to $count return $str),
				                                  $separator)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="for $i in 1 to $count
				    return ($str, if ($i lt $count) then $separator else ())"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xsl:function name="slsFn:get-gap-space-extent-text" as="xs:string" cache="yes">
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

</xsl:stylesheet>