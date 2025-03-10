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

	<!--
	Insert a section with a list of footnotes in the text or in a specific
	section.
	-->
	<xsl:template name="list-footnotes">
		<xsl:param name="section-id" as="xs:string?"/>

		<xsl:where-populated>
			<xsl:if test=".//tei:div[@xml:id eq $section-id]//tei:note
			              or .//tei:note">
				<xsl:text>&#10;</xsl:text> <!-- Newline -->
			</xsl:if>
			<section role="doc-endnotes">
				<xsl:if test="parent::tei:text[@xml:lang]">
					<xsl:attribute name="lang"
					               select="parent::tei:text/@xml:lang"/>
				</xsl:if>
				<!-- The footnotes section should have a heading for
				     accessibility -->
				<xsl:where-populated>
					<ol class="footnotesList">
						<xsl:for-each select="
							if (exists($section-id)
						        and string-length($section-id) gt 0)
						        then .//tei:div[@xml:id eq $section-id]//tei:note
						    else .//tei:note
						">
							<xsl:call-template name="add-footnote-list-item"/>
						</xsl:for-each>
					</ol>
				</xsl:where-populated>
			</section>
		</xsl:where-populated>
	</xsl:template>


	<!-- Insert a footnote list item in a list of footnotes. -->
	<xsl:template name="add-footnote-list-item">
		<xsl:if test="@place and @xml:id">
			<li data-id="{@xml:id}" class="footnoteItem">
				<xsl:call-template name="set-attr-from-xml-lang"/>
				<a href="#{@xml:id}" class="xreference footnoteReference"
				   rel="nofollow" role="doc-backlink">
					<xsl:text>{ if (@n) then @n else '*)' } </xsl:text>
				</a>
				<span class="footnoteText">
					<xsl:apply-templates/>
				</span>
			</li>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-xml-id">
		<xsl:param name="target-attr" as="xs:string" select="'data-id'"/>

		<xsl:if test="@xml:id">
			<xsl:attribute name="{$target-attr}" select="@xml:id"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-parent-xml-id">
		<xsl:param name="target-attr" as="xs:string" select="'data-id'"/>

		<xsl:if test="parent::*[@xml:id]">
			<xsl:attribute name="{$target-attr}" select="parent::*/@xml:id"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-key">
		<xsl:param name="target-attr" as="xs:string" select="'data-id'"/>

		<xsl:if test="@key">
			<xsl:attribute name="{$target-attr}" select="@key"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-xml-lang">
		<xsl:param name="target-attr" as="xs:string" select="'lang'"/>

		<xsl:if test="@xml:lang">
			<xsl:attribute name="{$target-attr}" select="@xml:lang"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-parent-xml-lang">
		<xsl:param name="target-attr" as="xs:string" select="'lang'"/>

		<xsl:if test="parent::*[@xml:lang]">
			<xsl:attribute name="{$target-attr}" select="parent::*/@xml:lang"/>
		</xsl:if>
	</xsl:template>


	<!--
	If the input parameter is a sequence of strings with class
	names, outputs @class with the class names separated by space as
	value.
	-->
	<xsl:template name="set-class-attr">
		<xsl:param name="class-names" as="xs:string*" select="()"/>

		<xsl:if test="exists($class-names)">
			<xsl:attribute name="class" select="$class-names"/>
		</xsl:if>
	</xsl:template>


	<!-- Adds @class from @rend. -->
	<xsl:template name="set-class-attr-from-rend">
		<xsl:call-template name="set-class-attr">
			<xsl:with-param name="class-names" select="(@rend)"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="add-paragraph-number">
		<xsl:if test="@n">
			<span aria-hidden="true" class="pNumber">
				<xsl:text>{@n} </xsl:text>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template name="add-line-number">
		<xsl:if test="@n and (@n mod 5 eq 0)">
			<span aria-hidden="true" class="lNumber">
				<xsl:text>{@n} </xsl:text>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template name="wrap-head-opener-in-hgroup">
	<!-- Group adjacent head/opener nodes -->
		<xsl:param name="nodes" as="node()*"/>

		<xsl:for-each-group select="$nodes"
		                    group-adjacent="if (self::tei:head or self::tei:opener)
		                                        then 'hgroup'
		                                    else 'other'">
			<xsl:choose>
				<!-- Only wrap in <hgroup> if there are at least two
				     adjacent head/opener nodes -->
				<xsl:when test="current-grouping-key() eq 'hgroup'
				                and count(current-group()) gt 1">
					<hgroup>
						<xsl:for-each select="current-group()">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</hgroup>
				</xsl:when>
				<!-- Otherwise, process the nodes normally -->
				<xsl:otherwise>
					<xsl:apply-templates select="current-group()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>


	<xsl:template name="add-gap-space-content">
		<xsl:param name="text-type" as="xs:string" select="'est'"/>
		
		<xsl:variable name="reason" as="xs:string"
		              select="if (not(@reason)
		                          and parent::tei:del[parent::tei:subst])
		                          then 'overwritten'
		                      else if (not(@reason))
		                          then 'writing'
		                      else @reason"/>
		<xsl:variable name="unit" as="xs:string"
		              select="if (@unit) then @unit else 'words'"/>
		<xsl:variable name="quantity" as="xs:integer"
		              select="if (@quantity and @quantity castable as xs:integer)
		                          then xs:integer(@quantity)
		                      else 1"/>
		<xsl:variable name="extent-text" as="xs:string"
		              select="slsFn:get-gap-space-extent-text($unit, $quantity)"/>

		<span>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('gap tooltiptrigger ttMs',
				                         if ($reason eq 'overstrike'
				                             or $reason eq 'erased')
				                             then 'deletion' else ())"/>
			</xsl:call-template>
			<xsl:text>[</xsl:text>
			<xsl:choose>
				<xsl:when test="$text-type eq 'est'">
					<xsl:sequence
						select="slsFn:get-gap-space-est-content(
							local-name(), $unit, $quantity
						)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>{
						if (local-name() eq 'gap')
						    then 'oläsligt'
						else 'tomrum'
					}</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>]</xsl:text>
		</span>
		<span class="tooltip" hidden="">
			<xsl:choose>
				<xsl:when test="local-name() eq 'gap'">
					<xsl:text>oläsligt ({$extent-text}), orsak: </xsl:text>
					<xsl:text>{slsFn:get-reason-text($reason)}</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>tomrum ({$extent-text})</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

</xsl:stylesheet>