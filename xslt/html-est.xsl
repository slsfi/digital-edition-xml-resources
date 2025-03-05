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
	XSLT stylesheet: est.xsl
	Version 1.0.0
	Author: Sebastian Köhler, Svenska litteratursällskapet i Finland,
		https://www.sls.fi/
	Created: 2025-02-21
	Changes:
		- 2025-02-21: v1.0.0

	Description:
	
	-->

	<!-- SERIALIZATION OPTIONS **************************************** -->

	<xsl:output method="html" html-version="5.0" encoding="utf-8"
	            include-content-type="no" indent="yes"/>

	<xsl:strip-space elements="tei:TEI tei:teiHeader tei:text tei:body
	                           tei:div tei:opener tei:list tei:table
	                           tei:row tei:argument tei:epigraph tei:cit
	                           tei:lg"/>


	<!-- IMPORTS -->

	<xsl:import href="shared-functions.xsl"/>
	<xsl:import href="shared-named-templates.xsl"/>


	<!-- PARAMETERS *************************************************** -->

	<!--
	Declare input parameters, if undefined, set to empty sequence.
	These should not be used in the stylesheet, but rather the global
	variables derived from these below.
	-->
	<xsl:param name="bookId" as="xs:string?" select="()"/>
	<xsl:param name="sectionId" as="xs:string?" select="()"/>


	<!-- GLOBAL VARIABLES ********************************************* -->

	<!--
	Normalize $bookId to be either a non-empty string or the empty
	sequence, and store in a global variable called $collection-id.
	-->
	<xsl:variable name="collection-id" as="xs:string?"
	              select="if (string-length($bookId) gt 0)
	                      then $bookId
	                      else ()"/>
	
	<!--
	Normalize $sectionId to be either a non-empty string or the empty
	sequence, and store in a global variable called $section-id.
	-->
	<xsl:variable name="section-id" as="xs:string?"
	              select="if (string-length($sectionId) gt 0)
	                      then $sectionId
	                      else ()"/>

	<!--
	An integer offset to add to the heading levels in the output. If
	set to 0, the top-most heading will be a <h1>, if set to 1, the
	top-most heading will be a <h2>, etc. Because the output HTML is
	embedded in a webpage with pre-existing headings, the heading
	levels need to be offset.
	-->
	<xsl:variable name="heading-level-offset" as="xs:integer" static="yes"
	              select="0"/>

	<!--
	Directory base path where icon images are located on the frontend.
	-->
	<xsl:variable name="icons-base-path" as="xs:string" static="yes"
	              select="'assets/images'"/>

	<!--
	Image element with icon representing empty content.
	-->
	<xsl:variable name="empty-icon-image" as="element(img)">
		<img src="{$icons-base-path}/squared_times_gray.svg"
		     alt="tomt" loading="lazy" aria-hidden="true"/>
	</xsl:variable>


	<!-- TEMPLATES **************************************************** -->
	<!-- Reminder on XSLT default behaviour for unmatched nodes:
	     element nodes are unwrapped and children processed (same as
	     apply-templates applied to them); the content (text) of text
	     nodes is outputted. -->


	<!-- * Template for <teiHeader>, which is stripped from the output. -->
	<xsl:template match="tei:teiHeader"/>


	<xsl:template match="tei:body[not(parent::tei:floatingText)]">
	<!-- * Template for <body> elements that are not children of
	       <floatingText>. If the global parameter $section-id is set,
	       process only the <div> with matching @xml:id. The content
	       of <body> is wrapped in <section> if it contains a child
	       <head>, otherwise in a <div>. @class is set with the @type
	       of the parent, <text>. Also @xml:id and @xml:lang are
	       inherited from <text>. Any footnotes either in the whole
	       <body> or just the processed section-id are appended as a
	       <section>. -->
		<xsl:choose>
			<xsl:when test="exists($section-id)">
				<xsl:apply-templates select="//tei:div[@xml:id eq $section-id]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="class-names" as="xs:string*"
				              select="(if (parent::tei:text[@type])
				                       then parent::tei:text/@type else 'prose')"/>
				<xsl:variable name="element-name" as="xs:string"
				              select="if (tei:head)
				                      then 'section' else 'div'"/>

				<xsl:choose>
					<xsl:when test="$element-name eq 'div' and empty($class-names)
					                and not(parent::tei:text[@xml:id])
					                and not(parent::tei:text[@xml:lang])">
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{$element-name}">
							<xsl:call-template name="add-id-attribute">
								<xsl:with-param name="from-parent" select="true()"/>
							</xsl:call-template>
							<xsl:call-template name="add-lang-attribute">
								<xsl:with-param name="from-parent" select="true()"/>
							</xsl:call-template>
							<xsl:call-template name="add-class-attribute">
								<xsl:with-param name="class-names"
								                select="$class-names"/>
							</xsl:call-template>

							<xsl:call-template name="wrap-head-opener-in-hgroup">
								<xsl:with-param name="nodes" select="node()"/>
							</xsl:call-template>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<!-- Process any footnotes so they appear after the main text. -->
		<xsl:call-template name="list-footnotes">
			<xsl:with-param name="section-id" select="$section-id"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="tei:div">
	<!-- * Template for <div> elements. If the <div> has a <head> child
	       or @type of the <div> is 'letterpart', wrap in <section>,
	       otherwise in a <div>. However, a <div> without attributes will
	       not be outputted. The @type value will be added as a class
	       name to @class, and if the type changes, the class name
	       'incorp' will also be added. -->
		<xsl:variable name="class-names" as="xs:string*"
		              select="(@type,
		                       if (ancestor::tei:div[@type][1]/@type ne current()/@type or
		                          (parent::tei:body
		                           and ancestor::tei:text/@type ne current()/@type))
		                       then 'incorp' else ())"/>
		
		<xsl:variable name="element-name" as="xs:string"
		              select="if (*[self::tei:head] or (@type eq 'letterpart'))
		                      then 'section' else 'div'"/>

		<xsl:choose>
			<xsl:when test="$element-name eq 'div' and empty($class-names)
			                and not(@xml:id) and not(@xml:lang)">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$element-name}">
					<xsl:call-template name="add-id-attribute"/>
					<xsl:call-template name="add-lang-attribute"/>
					<xsl:call-template name="add-class-attribute">
						<xsl:with-param name="class-names" select="$class-names"/>
					</xsl:call-template>

					<xsl:call-template name="wrap-head-opener-in-hgroup">
						<xsl:with-param name="nodes" select="node()"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:head[not(parent::tei:figure)
	                     and not(parent::tei:table)
	                     and not(@type eq 'subtitle')]">
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
			<xsl:attribute name="class" select="if (@type)
			                                    then @type else 'chapter'"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:head[@type eq 'subtitle']">
		<p role="doc-subtitle"><xsl:apply-templates/></p>
	</xsl:template>


	<xsl:template match="tei:head[parent::tei:table]">
		<caption><xsl:apply-templates/></caption>
	</xsl:template>


	<xsl:template match="tei:p[parent::tei:argument] | tei:byline | tei:dateline |
	                     tei:bibl[ancestor::tei:opener] | tei:ab[parent::tei:epigraph]">
		<p>
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="(if (parent::tei:argument)
				                         then 'argument'
				                         else if (local-name() ne 'p')
				                         then local-name() else (),
				                         if (ancestor::tei:epigraph)
				                         then 'epigraph' else (),
				                         @rend)"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:p">
		<p>
			<xsl:call-template name="add-id-attribute"/>
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute-from-rend"/>
			<xsl:call-template name="add-paragraph-number"/>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:date">
		<xsl:choose>
			<xsl:when test="@rend">
				<span>
					<xsl:call-template name="add-class-attribute-from-rend"/>
					<xsl:apply-templates/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:quote">
		<xsl:variable name="element-name" as="xs:string"
		              select="if (@type eq 'block' and not(ancestor::tei:opener))
		                      then 'blockquote' else 'p'"/>

		<xsl:element name="{$element-name}">
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="(if ($element-name eq 'p')
				                         then 'quote' else (),
				                         if (ancestor::tei:epigraph)
				                         then 'epigraph' else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:q[@rend eq 'parIndent']">
		<div class="q parIndent">
			<xsl:apply-templates/>
		</div>
	</xsl:template>


	<xsl:template match="tei:lg">
		<p>
			<xsl:call-template name="add-id-attribute"/>
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="('lg', @type)"/>
			</xsl:call-template>
			<xsl:call-template name="add-paragraph-number"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:l">
		<xsl:variable name="lg-type" as="xs:string?" select="parent::tei:lg/@type"/>
		<xsl:variable name="line-label" as="xs:string?"
		              select="if ($lg-type eq 'labelledLinesBefore'
				                  or $lg-type eq 'labelledLinesAfter')
				              then $lg-type else ()"/>
		<span>
			<xsl:call-template name="add-id-attribute"/>
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="('l', @rend,
				                         if (@part) then 'part' || @part
				                         else ())"/>
			</xsl:call-template>
			<xsl:call-template name="add-line-number"/>
			<xsl:choose>
				<xsl:when test="$line-label and tei:label">
					<xsl:choose>
						<xsl:when test="tei:label is node()[1]">
							<span class="lLabel">
								<xsl:apply-templates select="tei:label"/>
							</span>
							<span>
								<xsl:apply-templates select="node() except tei:label"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<span>
								<xsl:apply-templates select="node() except tei:label"/>
							</span>
							<span class="lLabel">
								<xsl:apply-templates select="tei:label"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
		<xsl:if test="not(. is (ancestor::tei:lg//tei:l[last()]))">
			<br/><xsl:text>&#10;</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:label">
		<xsl:choose>
			<xsl:when test="parent::tei:lg[@type eq 'labelledAbove'
			                               or @type eq 'labelledMargin']
			                and @place">
				<span class="label{substring(@place, 1, 1) => upper-case()}{substring(@place, 2)}">
					<xsl:apply-templates/>
				</span><xsl:text>&#10;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:list">
		<xsl:element name="{if (not(@rend) or @rend eq 'indent'
		                        or @rend eq 'disc' or @rend eq 'dash')
		                    then 'ul' else 'ol'}">
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="(if (@rend) then @rend else 'plain',
				                         if (parent::tei:argument)
				                         then 'argument' else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="tei:item">
		<li>
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:apply-templates/>
		</li>
	</xsl:template>


	<xsl:template match="tei:table">
	<!-- * Tables are wrapped in a <div> so large tables can be
		   scrolled horizontally. -->
		<div class="table-wrapper">
			<table>
				<xsl:call-template name="add-id-attribute"/>
				<xsl:call-template name="add-lang-attribute"/>
				<xsl:call-template name="add-class-attribute-from-rend"/>

				<!-- Group the rows so the first child rows with
					 @role="label" are wrapped in <thead> and the
					 subsequent rows are wrapped in <tbody>. -->
				<xsl:for-each-group select="node()"
					group-adjacent="if (self::tei:row[@role eq 'label']
					                    and (not(preceding-sibling::*)
					                         or preceding-sibling::tei:row[1][@role eq 'label']))
				                    then 'thead' else 'tbody'">
					<xsl:element name="{current-grouping-key()}">
						<xsl:for-each select="current-group()">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each-group>
			</table>
		</div>
	</xsl:template>


	<xsl:template match="tei:row">
		<tr><xsl:apply-templates/></tr>
	</xsl:template>


	<xsl:template match="tei:cell">
		<xsl:variable name="is-header" as="xs:boolean"
		              select="if (parent::tei:row[@role eq 'label']
		                          or @role eq 'label')
		                      then true() else false()"/>
		<xsl:variable name="colspan" as="xs:integer?"
		              select="let $parent-cols := parent::tei:row/@cols,
		                          $cols-str := if ($parent-cols)
		                                       then $parent-cols else @cols,
		                          $cols-int := if ($cols-str castable as xs:integer)
		                                       then xs:integer($cols-str)
		                                       else ()
		                      return if ($cols-int gt 1)
		                             then $cols-int else ()"/>
		<xsl:variable name="rowspan" as="xs:integer?"
		              select="let $rows-int := if (@rows castable as xs:integer)
		                                       then xs:integer(@rows)
		                                       else ()
		                      return if ($rows-int gt 1)
		                             then $rows-int else ()"/>

		<xsl:element name="{if ($is-header) then 'th' else 'td'}">
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="distinct-values((@rend,
				                                         parent::tei:row/@rend))"/>
			</xsl:call-template>
			<xsl:where-populated>
				<xsl:attribute name="colspan" select="$colspan"/>
			</xsl:where-populated>
			<xsl:where-populated>
				<xsl:attribute name="rowspan" select="$rowspan"/>
			</xsl:where-populated>
			<xsl:where-populated>
				<xsl:attribute name="scope"
				               select="if ($is-header and $colspan)
				                       then 'colgroup'
				                       else if ($is-header and $rowspan)
				                       then 'rowgroup'
				                       else if (@role eq 'label'
				                                and not(preceding-sibling::*)
				                                and not(following-sibling::tei:cell[@role eq 'label']))
				                       then 'row'
				                       else if ($is-header)
				                       then 'col'
				                       else ()"/>
			</xsl:where-populated>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:pb">
		<xsl:element name="{if (preceding-sibling::*[1][self::tei:p or self::tei:quote]
		                        or following-sibling::*[1][self::tei:p or self::tei:quote])
		                    then 'div' else 'span'}">
			<xsl:call-template name="add-id-attribute"/>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="('pb', @type)"/>
			</xsl:call-template>
			<xsl:attribute name="role">doc-pagebreak</xsl:attribute>
			<xsl:variable name="delimiter"
			              select="if (empty(@subtype)) then '|' else '['"/>
			<xsl:text>{$delimiter}{@n}{if ($delimiter eq '|') then '|' else ']'}</xsl:text>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:lb">
		<br/>
	</xsl:template>
	
	
	<xsl:template match="tei:milestone">
		<xsl:choose>
			<xsl:when test="@type">
				<hr class="milestone {@type}"/>
			</xsl:when>
			<xsl:when test="@unit eq 'part' and (@when or @source)">
				<div class="milestone milestonePart">
					<xsl:variable name="milestone-date" as="xs:string?"
					              select="slsFn:format-date-or-year(@when)"/>
					<xsl:variable name="milestone-source" as="xs:string?"
					              select="slsFn:decode-uri-encoded-colons(@source)"/>
					<xsl:text>Publicerad{if ($milestone-source) then ' i ' || $milestone-source else ''}{if ($milestone-date) then ' ' || $milestone-date else ''}</xsl:text>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<hr class="milestone blank"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:note">
		<xsl:if test="@place and @xml:id">
			<span tabindex="0" role="doc-noteref">
				<xsl:call-template name="add-id-attribute"/>
				<xsl:call-template name="add-lang-attribute"/>
				<xsl:call-template name="add-class-attribute">
					<xsl:with-param name="class-names"
					                select="('footnoteindicator tooltiptrigger ttFoot', @xml:id)"/>
				</xsl:call-template>
				<xsl:text>{@n}</xsl:text>
			</span>
			<span class="tooltip ttFoot">
				<span class="tei ttFixed">
					<xsl:call-template name="add-id-attribute"/>
					<xsl:apply-templates/>
				</span>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:figure">
		<xsl:choose>
			<xsl:when test="@type eq 'placeholder'">
				<!-- TODO: implement placeholder figure -->
			</xsl:when>
		</xsl:choose>
		<figure>
			<xsl:call-template name="add-id-attribute"/>
			<xsl:apply-templates/>
		</figure>
	</xsl:template>


	<xsl:template match="tei:head[parent::tei:figure]">
		<figcaption><xsl:apply-templates/></figcaption>
	</xsl:template>


	<xsl:template match="tei:graphic">
		<xsl:if test="not(parent::tei:figure[@type eq 'placeholder'])">
			<xsl:variable name="fig-desc"
		                  select="parent::tei:figure/tei:figDesc"/>
			<img src="{@url}" alt="{if ($fig-desc) then string($fig-desc) else 'illustration'}" loading="lazy">
				<xsl:where-populated>
					<xsl:attribute name="height" select="translate(@height, 'px', '')"/>
				</xsl:where-populated>
				<xsl:where-populated>
					<xsl:attribute name="width" select="translate(@width, 'px', '')"/>
				</xsl:where-populated>
			</img>
		</xsl:if>
	</xsl:template>
	
	
	<!-- <figDesc> is handled by the template for <graphic> -->
	<xsl:template match="tei:figDesc"/>
	

	<xsl:template match="tei:hi">
		<span>
			<xsl:call-template name="add-lang-attribute"/>
			<xsl:call-template name="add-class-attribute-from-rend"/>
			<xsl:apply-templates/>
		</span>
	</xsl:template>


	<xsl:template match="tei:unclear">
	<!-- If @reason is 'overstrike' or 'overwritten' the content is stripped. -->
		<xsl:if test="not(@reason) or (@reason ne 'overstrike' and @reason ne 'overwritten')">
			<xsl:variable name="reason" as="xs:string"
			              select="if (not(@reason) and parent::tei:del[parent::tei:subst])
			                          then 'overwritten'
			                      else if (not(@reason))
			                          then 'writing'
			                      else @reason"/>
			<span class="unclear tooltiptrigger ttMs">
				<xsl:apply-templates/>
			</span>
			<span class="tooltip">
				<xsl:text>svårtytt, orsak: {slsFn:get-reason-text($reason)}</xsl:text>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:gap | tei:space">
		<xsl:if test="not(@reason) or (@reason ne 'overstrike'
		                               and @reason ne 'overwritten'
		                               and @reason ne 'erased')">
			<xsl:call-template name="add-gap-space-content"/>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:del"/>


	<xsl:template match="tei:supplied">
		<span class="corr_red choice tooltiptrigger ttChanges">
			<xsl:apply-templates/>
		</span>
		<span class="tooltip ttChanges">
			<xsl:text>{
				if (@reason)
				    then 'oläsligt, orsak: ' || slsFn:get-reason-text(@reason)
				else if (@source)
				    then 'tillagt av utgivaren (källa för ändring: ' || @source || ')'
				else 'tillagt av utgivaren'
			}</xsl:text>
		</span>
	</xsl:template>


	<xsl:template match="tei:choice">
		<span>
			<xsl:call-template name="add-class-attribute">
				<xsl:with-param name="class-names"
				                select="('tooltiptrigger',
				                         if (tei:abbr) then 'abbr ttAbbreviations'
				                         else if (tei:orig) then 'choice ttChanges'
				                         else 'choice')"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</span>
		<xsl:choose>
			<xsl:when test="tei:expan">
				<span class="tooltip ttAbbreviations">
					<xsl:apply-templates select="tei:expan/node()"/>
				</span>
			</xsl:when>
			<xsl:when test="tei:orig">
				<span class="tooltip ttChanges">
					<xsl:text>original: </xsl:text>
					<xsl:apply-templates select="tei:orig/node()"/>
					<xsl:if test="tei:reg[@source]">
						<xsl:text> (källa för ändring: {tei:reg/@source})</xsl:text>
					</xsl:if>
				</span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:expan | tei:orig | tei:rdg"/>


	<xsl:template match="tei:abbr">
		<span class="abbr">
			<xsl:apply-templates/>
		</span>
	</xsl:template>


	<xsl:template match="tei:reg">
		<xsl:choose>
			<xsl:when test="parent::tei:choice">
				<span class="corr{if (@type eq 'empty') then ' corr_hide' else ''}">
					<xsl:choose>
						<xsl:when test="@type eq 'empty'">
							<xsl:sequence select="$empty-icon-image"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<span class="reg{if (@type eq 'empty') then '_hide' else ''} tooltiptrigger ttNormalisations">
					<xsl:choose>
						<xsl:when test="@type eq 'empty'">
							<xsl:sequence select="$empty-icon-image"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<span class="tooltip ttNormalisations">
					<xsl:text>konsekvensändrat/normaliserat</xsl:text>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:app">
		<span class="choice tooltiptrigger ttChanges">
			<xsl:apply-templates/>
		</span>
		<span class="tooltip ttChanges">
			<xsl:text>tryckvarians{if (tei:lem/@wit) then ', källa: ' || tei:lem/@wit else ''}</xsl:text>
			<xsl:text>; lydelse i övriga textvittnen:</xsl:text>
			<xsl:for-each select="tei:rdg">
				<br/>
				<xsl:apply-templates select="node()"/>
				<xsl:if test="@wit">
					<xsl:text> ({@wit})</xsl:text>
				</xsl:if>
			</xsl:for-each>		
		</span>
	</xsl:template>


	<xsl:template match="tei:lem">
		<span class="corr{if (@type eq 'empty') then ' corr_hide' else ''}">
			<xsl:choose>
				<xsl:when test="@type eq 'empty'">
					<xsl:sequence select="$empty-icon-image"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>


	<xsl:template match="tei:corr">
		<span class="corr{if (@type eq 'empty') then '_hide' else '_red'} tooltiptrigger ttChanges">
			<xsl:choose>
				<xsl:when test="@type eq 'empty'">
					<xsl:sequence select="$empty-icon-image"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
		<span class="tooltip ttChanges">
			<xsl:text>{if (@source) then @source else 'rättelse i originalet'}</xsl:text>
		</span>
	</xsl:template>

</xsl:stylesheet>