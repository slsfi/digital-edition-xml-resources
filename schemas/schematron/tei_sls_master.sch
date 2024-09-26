<?xml version="1.0" encoding="utf-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <title>ISO Schematron rules</title>
   <!-- This file generated 2024-09-26T08:49:35Z by 'extract-isosch.xsl'. -->

   <!-- ********************* -->
   <!-- namespaces, declared: -->
   <!-- ********************* -->
   <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
   <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
   <ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
   <ns prefix="rna" uri="http://relaxng.org/ns/compatibility/annotations/1.0"/>
   <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
   <ns prefix="sch1x" uri="http://www.ascc.net/xml/schematron"/>

   <!-- ********************* -->
   <!-- namespaces, implicit: -->
   <!-- ********************* -->


   <!-- ************ -->
   <!-- constraints: -->
   <!-- ************ -->
   <pattern id="schematron-constraint-tei_sls-att.cmc-generatedBy-CMC_generatedBy_within_post-1">
          <rule context="tei:*[@generatedBy]">
            <assert test="ancestor-or-self::tei:post">The @generatedBy attribute is for use within a &lt;post&gt; element.</assert>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls-att.datable.w3c-att-datable-w3c-when-2">
      <rule context="tei:*[@when]">
        <report test="@notBefore|@notAfter|@from|@to" role="nonfatal">The @when attribute cannot be used with any other att.datable.w3c attributes.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-att.datable.w3c-att-datable-w3c-from-3">
      <rule context="tei:*[@from]">
        <report test="@notBefore" role="nonfatal">The @from and @notBefore attributes cannot be used together.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-att.datable.w3c-att-datable-w3c-to-4">
      <rule context="tei:*[@to]">
        <report test="@notAfter" role="nonfatal">The @to and @notAfter attributes cannot be used together.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-att.global.source-source-only_1_ODD_source-5">
          <rule context="tei:*[@source]">
            <let name="srcs" value="tokenize( normalize-space(@source),' ')"/>
            <report test="( self::tei:classRef               | self::tei:dataRef               | self::tei:elementRef               | self::tei:macroRef               | self::tei:moduleRef               | self::tei:schemaSpec )               and               $srcs[2]">
              When used on a schema description element (like
              <value-of select="name(.)"/>), the @source attribute
              should have only 1 value. (This one has <value-of select="count($srcs)"/>.)
            </report>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls-att.typed-subtypeTyped-6">
      <rule context="tei:*[@subtype]">
        <assert test="@type">The <name/> element should not be categorized in detail with @subtype unless also categorized in general with @type</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-att.pointing-targetLang-targetLang-7">
          <rule context="tei:*[not(self::tei:schemaSpec)][@targetLang]">
            <assert test="@target">@targetLang should only be used on <name/> if @target is specified.</assert>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls-att.spanning-spanTo-spanTo-points-to-following-8">
          <rule context="tei:*[@spanTo]">
            <assert test="id(substring(@spanTo,2)) and following::*[@xml:id=substring(current()/@spanTo,2)]">
The element indicated by @spanTo (<value-of select="@spanTo"/>) must follow the current element <name/>
            </assert>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls-att.calendarSystem-calendar-calendar_attr_on_empty_element-9">
          <rule context="tei:*[@calendar]">
            <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
              systems or calendars to which the date represented by the content of this element belongs,
              but this <name/> element has no textual content.</assert>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls-p-abstractModel-structure-p-in-ab-or-p-10">
      <rule context="tei:p">
        <report test="(ancestor::tei:ab or ancestor::tei:p) and                        not( ancestor::tei:floatingText                           | parent::tei:exemplum                           | parent::tei:item                           | parent::tei:note                           | parent::tei:q                           | parent::tei:quote                           | parent::tei:remarks                           | parent::tei:said                           | parent::tei:sp                           | parent::tei:stage                           | parent::tei:cell                           | parent::tei:figure )">
          Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-p-abstractModel-structure-p-in-l-or-lg-11">
      <rule context="tei:p">
        <report test="( ancestor::tei:l  or  ancestor::tei:lg ) and                        not( ancestor::tei:floatingText                           | parent::tei:figure                           | parent::tei:note )">
          Abstract model violation: Lines may not contain higher-level structural elements such as div, p, or ab, unless p is a child of figure or note, or is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-name-calendar-calendar-check-name-12">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls-ptr-ptrAtts-13">
      <rule context="tei:ptr">
        <report test="@target and @cRef">Only one of the attributes @target and @cRef may be supplied on <name/>.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-ref-refAtts-14">
      <rule context="tei:ref">
        <report test="@target and @cRef">Only one of the attributes @target' and @cRef' may be supplied on <name/>
         </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-list-gloss-list-must-have-labels-15">
      <rule context="tei:list[@type='gloss']">
	        <assert test="tei:label">The content of a "gloss" list should include a sequence of one or more pairs of a label element followed by an item element</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-author-calendar-calendar-check-author-16">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls-resp-calendar-calendar-check-resp-17">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls-title-calendar-calendar-check-title-18">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls-l-abstractModel-structure-l-in-l-19">
      <rule context="tei:l">
        <report test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">Abstract model violation: Lines may not contain lines or lg elements.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-lg-atleast1oflggapl-20">
      <rule context="tei:lg">
        <assert test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0">An lg element must contain at least one child l, lg, or gap element.</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-lg-abstractModel-structure-lg-in-l-21">
      <rule context="tei:lg">
        <report test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">Abstract model violation: Lines may not contain line groups.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-idno-calendar-calendar-check-idno-22">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls-licence-calendar-calendar-check-licence-23">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls-change-calendar-calendar-check-change-24">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
      
      
    
      
      
    
      
      
    <pattern id="schematron-constraint-tei_sls-div-abstractModel-structure-div-in-l-or-lg-28">
      <rule context="tei:div">
        <report test="(ancestor::tei:l or ancestor::tei:lg) and not(ancestor::tei:floatingText)">
          Abstract model violation: Lines may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-div-abstractModel-structure-div-in-ab-or-p-29">
      <rule context="tei:div">
        <report test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)">
          Abstract model violation: p and ab may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-ab-abstractModel-structure-ab-in-l-or-lg-30">
      <rule context="tei:ab">
        <report test="(ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note )">
          Abstract model violation: Lines may not contain higher-level divisions such as p or ab, unless ab is a child of figure or note, or is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-addSpan-addSpan-requires-spanTo-31">
      <rule context="tei:addSpan">
        <assert test="@spanTo">The @spanTo attribute of <name/> is required.</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-delSpan-delSpan-requires-spanTo-33">
      <rule context="tei:delSpan">
        <assert test="@spanTo">The @spanTo attribute of <name/> is required.</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-subst-substContents1-35">
      <rule context="tei:subst">
        <assert test="child::tei:add and (child::tei:del or child::tei:surplus)">
            <name/> must have at least one child add and at least one child del or surplus</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls-persName-calendar-calendar-check-persName-36">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls-placeName-calendar-calendar-check-placeName-37">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>

   <!-- *********** -->
   <!-- deprecated: -->
   <!-- *********** -->
   <pattern>
      <rule context="tei:name">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the name element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:author">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the author element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:resp">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the resp element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:title">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the title element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:idno">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the idno element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:licence">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the licence element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:change">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the change element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:persName">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the persName element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:placeName">
         <report test="@calendar" role="nonfatal">WARNING: use of deprecated attribute — @calendar of the placeName element will be removed from the TEI on 2024-11-11.
                </report>
      </rule>
   </pattern>
</schema>
