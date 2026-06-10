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

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: shared-named-templates.xsl
	*
	*    Version: 1.4.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-03-07
	*    Licence: CC BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.4.0 (2025-11-20)
	*             - Added parameter to the `document-heading` template for
	*               adding a classname based on the heading level.
	*        v1.3.0 (2025-11-19)
	*             - Added parameter to the `list-footnotes` template for
	*               controlling if the template should wrap the footnotes
	*               list in a <section> element or not.
	*             - Added parameter to the `document-heading` template for
	*               specifying the default classname that should be added
	*               to headings that are missing @type, defaults to
	*               'chapter', which retains the previous behaviour.
	*        v1.2.0 (2025-09-11)
	*             - Add template `apply-templates-with-optional-form-
	*               shift-wrapper`.
	*             - Modify `document-heading` template to incorporate
	*               form-shift classname if applicable.
	*        v1.1.1 (2025-05-21)
	*             - Add fixed class name 'head' to headings.
	*        v1.1.0 (2025-04-24)
	*             - Add template `document-heading`.
	*             - Modify template `add-gap-space-content` to support
	*               manuscript texts.
	*             - Output newline characters only when `$debug` input
	*               parameter is true.
	*        v1.0.0 (2025-03-07)
	*
	*    Description:
	*        This XSLT document defines common named templates.
	*
	*    Dependencies:
	*        The `required-global-variables.xsl` and `shared-functions.xsl`
	*        must be imported before this stylesheet.
	*
	******************************************************************* -->


	<!-- * NAMED TEMPLATES ******************************************** -->

	<xsl:template name="list-footnotes">
	<!-- * Generates a list of footnotes.
	     * If a section ID is provided, it retrieves footnotes from that section.
	     * Otherwise, it collects all footnotes in the document. * -->
		<xsl:param name="section-id" as="xs:string?" select="()"/>
		<xsl:param name="create-wrapper" as="xs:boolean" select="true()"/>
		
		<xsl:variable name="text-node" as="element(tei:text)?"
			select="root(.)//tei:text"/>
		<xsl:variable name="note-nodes" as="element(tei:note)*"
			select="if (exists($section-id) and string-length($section-id) gt 0)
					    then $text-node//tei:div[@xml:id eq $section-id]//tei:note
					else $text-node//tei:note"/>
		
		<xsl:variable name="notes-list" as="element(*)?">
			<xsl:where-populated>
				<ol class="footnotesList">
					<xsl:for-each select="$note-nodes">
						<xsl:call-template name="add-footnote-list-item"/>
					</xsl:for-each>
				</ol>
			</xsl:where-populated>
		</xsl:variable>

		<xsl:where-populated>
			<xsl:if test="exists($note-nodes)">
				<xsl:text>{if ($debug) then $NL else ''}</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$create-wrapper">
					<section role="doc-endnotes">
						<xsl:if test="parent::tei:text[@xml:lang]">
							<xsl:attribute name="lang"
							               select="parent::tei:text/@xml:lang"/>
						</xsl:if>
						<!-- * TODO: The footnotes section should have a heading for
						     * accessibility. * -->
						<xsl:sequence select="$notes-list"/>
					</section>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$notes-list"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:where-populated>
	</xsl:template>


	<xsl:template name="add-footnote-list-item">
	<!-- * Creates a list item for a footnote.
	     * Includes a reference link and the footnote text. * -->
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
	<!-- * Sets an attribute (default "data-id") with the value of @xml:id 
	     * if it exists on the current element. * -->
		<xsl:param name="target-attr" as="xs:string" select="'data-id'"/>

		<xsl:if test="@xml:id">
			<xsl:attribute name="{$target-attr}" select="@xml:id"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-parent-xml-id">
	<!-- * Sets an attribute (default "data-id") with the @xml:id of the
	     * parent element if it exists. * -->
		<xsl:param name="target-attr" as="xs:string" select="'data-id'"/>

		<xsl:if test="parent::*[@xml:id]">
			<xsl:attribute name="{$target-attr}" select="parent::*/@xml:id"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-key">
	<!-- * Sets an attribute (default "data-id") with the value of @key 
	     * if it exists on the current element. * -->
		<xsl:param name="target-attr" as="xs:string" select="'data-id'"/>

		<xsl:if test="@key">
			<xsl:attribute name="{$target-attr}" select="@key"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-xml-lang">
	<!-- * Sets a language attribute (default "lang") using the @xml:lang 
	     * value from the current element if it exists. * -->
		<xsl:param name="target-attr" as="xs:string" select="'lang'"/>

		<xsl:if test="@xml:lang">
			<xsl:attribute name="{$target-attr}" select="@xml:lang"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-attr-from-parent-xml-lang">
	<!-- * Sets a language attribute (default "lang") using the @xml:lang 
	     * value from the parent element if it exists. * -->
		<xsl:param name="target-attr" as="xs:string" select="'lang'"/>

		<xsl:if test="parent::*[@xml:lang]">
			<xsl:attribute name="{$target-attr}" select="parent::*/@xml:lang"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-class-attr">
	<!-- * Sets a @class attribute from a sequence of class names as strings.
         * If multiple class names are provided, they are space-separated. * -->
		<xsl:param name="class-names" as="xs:string*" select="()"/>

		<xsl:if test="exists($class-names)">
			<xsl:attribute name="class" select="$class-names"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="set-class-attr-from-rend">
	<!-- * Copies the value of @rend to @class. * -->
		<xsl:call-template name="set-class-attr">
			<xsl:with-param name="class-names" select="(@rend)"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="add-paragraph-number">
	<!-- * Adds a paragraph number inside a span element.
	     * The number is taken from the @n attribute if it exists. * -->
		<xsl:if test="@n">
			<span aria-hidden="true" class="pNumber">
				<xsl:text>{@n} </xsl:text>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template name="add-line-number">
	<!-- * Adds a line number inside a span element.
	     * Only adds numbers that are multiples of 5 (e.g., 5, 10, 15). * -->
		<xsl:if test="@n and (@n mod 5 eq 0) and (not(@part) or @part eq 'I'
		                                          or @part eq 'N')">
			<span aria-hidden="true" class="lNumber">
				<xsl:text>{@n} </xsl:text>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template name="wrap-head-opener-in-hgroup">
	<!-- * Groups adjacent <head> and <opener> elements into an <hgroup>.
	     * Ensures proper semantic structure when multiple headings are
	     * present. * -->
		<xsl:param name="nodes" as="node()*"/>

		<xsl:for-each-group select="$nodes"
		                    group-adjacent="if (self::tei:head or self::tei:opener)
		                                        then 'hgroup'
		                                    else 'other'">
			<xsl:choose>
				<!-- * Only wrap in <hgroup> if there are at least two
				     * adjacent head/opener nodes. * -->
				<xsl:when test="current-grouping-key() eq 'hgroup'
				                and count(current-group()) gt 1">
					<hgroup>
						<xsl:for-each select="current-group()">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</hgroup>
				</xsl:when>
				<!-- * Otherwise, process the nodes normally. * -->
				<xsl:otherwise>
					<xsl:apply-templates select="current-group()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>


	<xsl:template name="add-gap-space-content">
	<!-- * Generates placeholder content for unreadable or missing text
	     * (gaps and spaces). The content varies based on the text type
	     * ("est" for reading-text/established text, "ms_changes" for
	     * manuscripts showing changes, and "ms_normalized" for
	     * manuscripts with changes applied). Also provides tooltip
	     * information with details about the gap/space. * -->
		<xsl:param name="text-type" as="xs:string" select="'est'"/>
		<xsl:param name="hand-tooltip-text" as="xs:string?" select="()"/>

		<xsl:variable name="reason" as="xs:string?"
		              select="if (local-name() eq 'space')
		                          then ()
		                      else (if (not(@reason)
			                            and parent::tei:del[parent::tei:subst])
			                            then 'overwritten'
			                        else if (not(@reason))
			                            then 'writing'
			                        else @reason)"/>
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
				                select="(local-name(),
				                         'tooltiptrigger ttMs',
				                         if ($reason eq 'overstrike'
				                             or $reason eq 'erased'
				                             or $reason eq 'overwritten')
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
			<xsl:if test="$text-type eq 'ms_changes' and $hand-tooltip-text">
				<br/>
				<xsl:text>{$hand-tooltip-text}</xsl:text>
			</xsl:if>
		</span>
	</xsl:template>


	<xsl:template name="document-heading">
	<!-- * Generates a heading element (h1–h6 or a div with @aria-level)
	     * based on the nesting of the context item and applies
	     * templates.
	     * If param add-heading-classname is true, a classname is added
	     * based on the heading level ("heading1", "heading2", etc.). * -->
		<xsl:param name="include-rend-attr" as="xs:boolean" select="false()"/>
		<xsl:param name="default-classname" as="xs:string?" select="'chapter'"/>
		<xsl:param name="add-heading-classname" as="xs:boolean" select="false()"/>

		<xsl:variable name="heading-level"
		              select="slsFn:get-heading-level(., $heading-level-offset)"/>
		<xsl:variable name="element-name"
		              select="if ($heading-level lt 7)
		                          then 'h' || $heading-level
		                      else 'div'"/>

		<xsl:element name="{$element-name}">
			<xsl:if test="$element-name eq 'div'">
				<xsl:attribute name="role" select="'heading'"/>
				<xsl:attribute name="aria-level" select="$heading-level"/>
			</xsl:if>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
					select="('head',
					         if (@type) then @type else $default-classname,
					         if ($include-rend-attr) then @rend else (),
					         if ($add-heading-classname) then 'heading' || $heading-level else (),
					         slsFn:get-form-shift-classname(.))"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template name="apply-templates-with-optional-form-shift-wrapper">
	<!-- * Applies templates and optionally wraps the content in a span
	     * element with the form-shift classname if applicable. * -->
		<xsl:variable name="form-shift-rend" select="slsFn:get-form-shift-classname(.)"/>
		<xsl:choose>
			<xsl:when test="$form-shift-rend">
				<span class="{$form-shift-rend}">
					<xsl:apply-templates/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>