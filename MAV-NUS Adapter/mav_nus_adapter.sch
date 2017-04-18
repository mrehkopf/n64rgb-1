<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE eagle SYSTEM "eagle.dtd">
<eagle version="7.6.0">
<drawing>
<settings>
<setting alwaysvectorfont="no"/>
<setting verticaltext="up"/>
</settings>
<grid distance="0.1" unitdist="inch" unit="inch" style="lines" multiple="1" display="no" altdistance="0.01" altunitdist="inch" altunit="inch"/>
<layers>
<layer number="1" name="Top" color="4" fill="1" visible="no" active="no"/>
<layer number="16" name="Bottom" color="1" fill="1" visible="no" active="no"/>
<layer number="17" name="Pads" color="2" fill="1" visible="no" active="no"/>
<layer number="18" name="Vias" color="2" fill="1" visible="no" active="no"/>
<layer number="19" name="Unrouted" color="6" fill="1" visible="no" active="no"/>
<layer number="20" name="Dimension" color="15" fill="1" visible="no" active="no"/>
<layer number="21" name="tPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="22" name="bPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="23" name="tOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="24" name="bOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="25" name="tNames" color="7" fill="1" visible="no" active="no"/>
<layer number="26" name="bNames" color="7" fill="1" visible="no" active="no"/>
<layer number="27" name="tValues" color="7" fill="1" visible="no" active="no"/>
<layer number="28" name="bValues" color="7" fill="1" visible="no" active="no"/>
<layer number="29" name="tStop" color="7" fill="3" visible="no" active="no"/>
<layer number="30" name="bStop" color="7" fill="6" visible="no" active="no"/>
<layer number="31" name="tCream" color="7" fill="4" visible="no" active="no"/>
<layer number="32" name="bCream" color="7" fill="5" visible="no" active="no"/>
<layer number="33" name="tFinish" color="6" fill="3" visible="no" active="no"/>
<layer number="34" name="bFinish" color="6" fill="6" visible="no" active="no"/>
<layer number="35" name="tGlue" color="7" fill="4" visible="no" active="no"/>
<layer number="36" name="bGlue" color="7" fill="5" visible="no" active="no"/>
<layer number="37" name="tTest" color="7" fill="1" visible="no" active="no"/>
<layer number="38" name="bTest" color="7" fill="1" visible="no" active="no"/>
<layer number="39" name="tKeepout" color="4" fill="11" visible="no" active="no"/>
<layer number="40" name="bKeepout" color="1" fill="11" visible="no" active="no"/>
<layer number="41" name="tRestrict" color="4" fill="10" visible="no" active="no"/>
<layer number="42" name="bRestrict" color="1" fill="10" visible="no" active="no"/>
<layer number="43" name="vRestrict" color="2" fill="10" visible="no" active="no"/>
<layer number="44" name="Drills" color="7" fill="1" visible="no" active="no"/>
<layer number="45" name="Holes" color="7" fill="1" visible="no" active="no"/>
<layer number="46" name="Milling" color="3" fill="1" visible="no" active="no"/>
<layer number="47" name="Measures" color="7" fill="1" visible="no" active="no"/>
<layer number="48" name="Document" color="7" fill="1" visible="no" active="no"/>
<layer number="49" name="Reference" color="7" fill="1" visible="no" active="no"/>
<layer number="51" name="tDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="52" name="bDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="90" name="Modules" color="5" fill="1" visible="yes" active="yes"/>
<layer number="91" name="Nets" color="2" fill="1" visible="yes" active="yes"/>
<layer number="92" name="Busses" color="1" fill="1" visible="yes" active="yes"/>
<layer number="93" name="Pins" color="2" fill="1" visible="no" active="yes"/>
<layer number="94" name="Symbols" color="4" fill="1" visible="yes" active="yes"/>
<layer number="95" name="Names" color="7" fill="1" visible="yes" active="yes"/>
<layer number="96" name="Values" color="7" fill="1" visible="yes" active="yes"/>
<layer number="97" name="Info" color="7" fill="1" visible="yes" active="yes"/>
<layer number="98" name="Guide" color="6" fill="1" visible="yes" active="yes"/>
</layers>
<schematic xreflabel="%F%N/%S.%C%R" xrefpart="/%S.%C%R">
<libraries>
<library name="wirepad">
<description>&lt;b&gt;Single Pads&lt;/b&gt;&lt;p&gt;
&lt;author&gt;Created by librarian@cadsoft.de&lt;/author&gt;</description>
<packages>
<package name="SMD0,8-1,6">
<smd name="P$1" x="0" y="0" dx="0.8" dy="1.6" layer="1"/>
<text x="-1.27" y="-1.27" size="1.27" layer="25" rot="R90">&gt;NAME</text>
</package>
<package name="SMD1,27-2,54">
<description>&lt;b&gt;SMD PAD&lt;/b&gt;</description>
<smd name="1" x="0" y="0" dx="1.27" dy="2.54" layer="1"/>
<text x="0" y="0" size="0.0254" layer="27">&gt;VALUE</text>
<text x="-0.8" y="-2.4" size="1.27" layer="25" rot="R90">&gt;NAME</text>
</package>
<package name="SMD0,45-1,35">
<smd name="P$1" x="0" y="0" dx="1.35" dy="0.45" layer="1"/>
</package>
</packages>
<symbols>
<symbol name="PAD">
<wire x1="-1.016" y1="1.016" x2="1.016" y2="-1.016" width="0.254" layer="94"/>
<wire x1="-1.016" y1="-1.016" x2="1.016" y2="1.016" width="0.254" layer="94"/>
<text x="-1.143" y="1.8542" size="1.778" layer="95">&gt;NAME</text>
<text x="-1.143" y="-3.302" size="1.778" layer="96">&gt;VALUE</text>
<pin name="P" x="2.54" y="0" visible="off" length="short" direction="pas" rot="R180"/>
</symbol>
</symbols>
<devicesets>
<deviceset name="SMD1">
<gates>
<gate name="G$1" symbol="PAD" x="0" y="2.54"/>
</gates>
<devices>
<device name="" package="SMD0,8-1,6">
<connects>
<connect gate="G$1" pin="P" pad="P$1"/>
</connects>
<technologies>
<technology name=""/>
</technologies>
</device>
</devices>
</deviceset>
<deviceset name="SMD2" prefix="PAD" uservalue="yes">
<description>&lt;b&gt;SMD PAD&lt;/b&gt;</description>
<gates>
<gate name="1" symbol="PAD" x="0" y="0"/>
</gates>
<devices>
<device name="" package="SMD1,27-2,54">
<connects>
<connect gate="1" pin="P" pad="1"/>
</connects>
<technologies>
<technology name=""/>
</technologies>
</device>
</devices>
</deviceset>
<deviceset name="SMD0,45">
<gates>
<gate name="G$1" symbol="PAD" x="0" y="0"/>
</gates>
<devices>
<device name="" package="SMD0,45-1,35">
<connects>
<connect gate="G$1" pin="P" pad="P$1"/>
</connects>
<technologies>
<technology name=""/>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
</libraries>
<attributes>
</attributes>
<variantdefs>
</variantdefs>
<classes>
<class number="0" name="default" width="0" drill="0">
</class>
</classes>
<parts>
<part name="U$14" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$15" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$16" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$17" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$18" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$19" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$20" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$21" library="wirepad" deviceset="SMD1" device=""/>
<part name="U$22" library="wirepad" deviceset="SMD1" device=""/>
<part name="PAD1" library="wirepad" deviceset="SMD2" device=""/>
<part name="PAD2" library="wirepad" deviceset="SMD2" device=""/>
<part name="U$1" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$2" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$3" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$4" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$5" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$6" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$7" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$8" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$9" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$10" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$11" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$12" library="wirepad" deviceset="SMD0,45" device=""/>
<part name="U$13" library="wirepad" deviceset="SMD0,45" device=""/>
</parts>
<sheets>
<sheet>
<plain>
</plain>
<instances>
<instance part="U$14" gate="G$1" x="17.78" y="40.64" rot="R180"/>
<instance part="U$15" gate="G$1" x="17.78" y="38.1" rot="R180"/>
<instance part="U$16" gate="G$1" x="17.78" y="35.56" rot="R180"/>
<instance part="U$17" gate="G$1" x="17.78" y="33.02" rot="R180"/>
<instance part="U$18" gate="G$1" x="17.78" y="30.48" rot="R180"/>
<instance part="U$19" gate="G$1" x="17.78" y="27.94" rot="R180"/>
<instance part="U$20" gate="G$1" x="17.78" y="25.4" rot="R180"/>
<instance part="U$21" gate="G$1" x="17.78" y="22.86" rot="R180"/>
<instance part="U$22" gate="G$1" x="17.78" y="20.32" rot="R180"/>
<instance part="PAD1" gate="1" x="17.78" y="17.78" rot="R180"/>
<instance part="PAD2" gate="1" x="17.78" y="12.7" rot="R180"/>
<instance part="U$1" gate="G$1" x="2.54" y="40.64"/>
<instance part="U$2" gate="G$1" x="2.54" y="38.1"/>
<instance part="U$3" gate="G$1" x="2.54" y="35.56"/>
<instance part="U$4" gate="G$1" x="2.54" y="33.02"/>
<instance part="U$5" gate="G$1" x="2.54" y="30.48"/>
<instance part="U$6" gate="G$1" x="2.54" y="27.94"/>
<instance part="U$7" gate="G$1" x="2.54" y="25.4"/>
<instance part="U$8" gate="G$1" x="2.54" y="22.86"/>
<instance part="U$9" gate="G$1" x="2.54" y="20.32"/>
<instance part="U$10" gate="G$1" x="2.54" y="17.78"/>
<instance part="U$11" gate="G$1" x="2.54" y="15.24"/>
<instance part="U$12" gate="G$1" x="2.54" y="12.7"/>
<instance part="U$13" gate="G$1" x="2.54" y="10.16"/>
</instances>
<busses>
</busses>
<nets>
<net name="N$1" class="0">
<segment>
<pinref part="U$14" gate="G$1" pin="P"/>
<wire x1="5.08" y1="40.64" x2="15.24" y2="40.64" width="0.1524" layer="91"/>
<pinref part="U$1" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$2" class="0">
<segment>
<pinref part="U$15" gate="G$1" pin="P"/>
<wire x1="15.24" y1="38.1" x2="5.08" y2="38.1" width="0.1524" layer="91"/>
<pinref part="U$2" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$3" class="0">
<segment>
<pinref part="U$16" gate="G$1" pin="P"/>
<wire x1="5.08" y1="35.56" x2="15.24" y2="35.56" width="0.1524" layer="91"/>
<pinref part="U$3" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$4" class="0">
<segment>
<pinref part="U$17" gate="G$1" pin="P"/>
<wire x1="5.08" y1="33.02" x2="15.24" y2="33.02" width="0.1524" layer="91"/>
<pinref part="U$4" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$5" class="0">
<segment>
<pinref part="U$18" gate="G$1" pin="P"/>
<wire x1="15.24" y1="30.48" x2="5.08" y2="30.48" width="0.1524" layer="91"/>
<pinref part="U$5" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$6" class="0">
<segment>
<pinref part="U$19" gate="G$1" pin="P"/>
<wire x1="5.08" y1="27.94" x2="15.24" y2="27.94" width="0.1524" layer="91"/>
<pinref part="U$6" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$7" class="0">
<segment>
<pinref part="U$20" gate="G$1" pin="P"/>
<wire x1="15.24" y1="25.4" x2="5.08" y2="25.4" width="0.1524" layer="91"/>
<pinref part="U$7" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$8" class="0">
<segment>
<pinref part="U$21" gate="G$1" pin="P"/>
<wire x1="5.08" y1="22.86" x2="15.24" y2="22.86" width="0.1524" layer="91"/>
<pinref part="U$8" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$9" class="0">
<segment>
<pinref part="U$22" gate="G$1" pin="P"/>
<wire x1="15.24" y1="20.32" x2="5.08" y2="20.32" width="0.1524" layer="91"/>
<pinref part="U$9" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$10" class="0">
<segment>
<wire x1="5.08" y1="17.78" x2="10.16" y2="17.78" width="0.1524" layer="91"/>
<wire x1="10.16" y1="17.78" x2="15.24" y2="17.78" width="0.1524" layer="91"/>
<wire x1="5.08" y1="15.24" x2="7.62" y2="15.24" width="0.1524" layer="91"/>
<wire x1="7.62" y1="15.24" x2="10.16" y2="17.78" width="0.1524" layer="91"/>
<junction x="10.16" y="17.78"/>
<pinref part="PAD1" gate="1" pin="P"/>
<pinref part="U$10" gate="G$1" pin="P"/>
<pinref part="U$11" gate="G$1" pin="P"/>
</segment>
</net>
<net name="N$11" class="0">
<segment>
<wire x1="5.08" y1="12.7" x2="10.16" y2="12.7" width="0.1524" layer="91"/>
<wire x1="10.16" y1="12.7" x2="15.24" y2="12.7" width="0.1524" layer="91"/>
<wire x1="5.08" y1="10.16" x2="7.62" y2="10.16" width="0.1524" layer="91"/>
<wire x1="7.62" y1="10.16" x2="10.16" y2="12.7" width="0.1524" layer="91"/>
<junction x="10.16" y="12.7"/>
<pinref part="PAD2" gate="1" pin="P"/>
<pinref part="U$12" gate="G$1" pin="P"/>
<pinref part="U$13" gate="G$1" pin="P"/>
</segment>
</net>
</nets>
</sheet>
</sheets>
</schematic>
</drawing>
</eagle>
