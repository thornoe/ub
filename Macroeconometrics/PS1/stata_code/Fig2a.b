StataFileTM:00001:01000:LiveGPH:                       :
00005:00004:
*! classname: twowaygraph_g
*! family: twoway
*! command: two  (hist u)                                                , title("Histogram")                    saving(Fig2a.b, replace)
*! command_date: 10 Dec 2018
*! command_time: 14:28:25
*! datafile: 
*! datafile_date: 
*! scheme: s1color
*! naturallywhite: 1
*! xsize: 5.5
*! ysize: 4
*! end
<BeginItem> serset Kb472a68 
<BeginSerset>
<BeginSeries>
.name = `"_height"'
.label = `"Density"'
.format = `"%6.4g"'
.type.set numeric
.min =  .0062986626289785
.max =  .3905170857906342
.median = (.)
.pct25 = (.)
.pct75 = (.)
.categories =  18
<EndSeries>
<BeginSeries>
.name = `"zero"'
.label = `"Density"'
.format = `"%8.0g"'
.type.set numeric
.min =  0
.max =  0
.median = (.)
.pct25 = (.)
.pct75 = (.)
.categories =  1
<EndSeries>
<BeginSeries>
.name = `"x"'
.label = `"u"'
.format = `"%9.0g"'
.type.set numeric
.min =  -3.513908624649048
.max =  3.154173612594605
.median = (.)
.pct25 = (.)
.pct75 = (.)
.categories =  21
<EndSeries>
.weight_id = (.)
<BeginSersetData>
sersetreadwrite       ���__000006                                                                                                                                              __000007                                                                                                                                              __000005                                                                                                                                              %6.4g                                                    %8.0g                                                    %9.0g                                                       `��y?            |�   `;��?           `�;	@e�; ��`�e�; ��L�e�; !?8�eN< ��#�b�4= b��eN= ����X> D�Ϳ�>!> �F���> �Cy�b��> �'���> a���ѷ> �ᬼ���> �ė>��> �+?�u> qun?"� > xߟ?�1�= 8��?�˚= �(�?��= ��@"� = ;9!@eN< ��I@
<EndSersetData>
<EndSerset>
<EndItem>
<BeginItem> scheme Kb572528 
.setscheme , scheme(s1color) naturallywhite(1)
<EndItem>
<BeginItem> twowaygraph_g K3937498 <UseScheme> Kb572528
.sersets[1] = .__Map.Kb472a68.ref
.insert (plotregion1 = .plotregion.new , style(scheme twoway) graph(`.objkey')) at 1 1
.plotregion1.Declare plot1 = .y2xview_g.new , type(rbar) serset(`.sersets[1].objkey') yvariable(`.sersets[1].seriesof _height') xvariable(`.sersets[1].seriesof x')    plotregion(`.plotregion1.objkey') style(scheme p1bar) ybvar(`.sersets[1].seriesof zero')
.plotregion1.plot1.style.setstyle, style(histogram)
.plotregion1.plot1.bar_drop_to.setstyle , style(x)
.plotregion1.plot1.bar_size = .3175277276472612
.plotregion1.plot1.register_with_scale
.plotregion1.plot1.bar_size = .3175277276472612*(100-0)/100
.plotregion1.plot1.register_with_scale
.plotregion1.clear_scales
.plotregion1.reset_scales , noclear
.n_views = 1
.n_plotregions = 1
.last_style = 1
.x_scales = `" "1""'
.y_scales = `" "1""'
.create_axes 1 1 "9" "" 9
.insert (legend = .legend_g.new, graphs(`.objkey') style(scheme)) below plotregion1 , ring(3) 
.legend.style.editstyle box_alignment(S) editcopy
.legend.insert (note = .sized_textbox.new, mtextq(`""') style(scheme leg_note) ) below plotregion1 , ring(3) 
.legend.note.style.editstyle box_alignment(SW) editcopy
.legend.note.style.editstyle horizontal(left) editcopy
.legend.insert (caption = .sized_textbox.new, mtextq(`""') style(scheme leg_caption) ) below plotregion1 , ring(5) 
.legend.caption.style.editstyle box_alignment(SW) editcopy
.legend.caption.style.editstyle horizontal(left) editcopy
.legend.insert (subtitle = .sized_textbox.new, mtextq(`""') style(scheme leg_subtitle) ) above plotregion1 , ring(6) 
.legend.subtitle.style.editstyle box_alignment(N) editcopy
.legend.subtitle.style.editstyle horizontal(center) editcopy
.legend.insert (title = .sized_textbox.new, mtextq(`""') style(scheme leg_title) ) above plotregion1 , ring(7) 
.legend.title.style.editstyle box_alignment(N) editcopy
.legend.title.style.editstyle horizontal(center) editcopy
.legend.rebuild
.legend.repositionkeys
.insert (r1title = .sized_textbox.new, mtextq(`""') style(scheme r1title) orientation(vertical)) rightof plotregion1 , ring(1) 
.insert (r2title = .sized_textbox.new, mtextq(`""') style(scheme r2title) orientation(vertical)) rightof plotregion1 , ring(2) 
.insert (l1title = .sized_textbox.new, mtextq(`""') style(scheme l1title) orientation(vertical)) leftof plotregion1 , ring(1) 
.insert (l2title = .sized_textbox.new, mtextq(`""') style(scheme l2title) orientation(vertical)) leftof plotregion1 , ring(2) 
.insert (t1title = .sized_textbox.new, mtextq(`""') style(scheme t1title) ) above plotregion1 , ring(1) 
.insert (t2title = .sized_textbox.new, mtextq(`""') style(scheme t2title) ) above plotregion1 , ring(2) 
.insert (b1title = .sized_textbox.new, mtextq(`""') style(scheme b1title) ) below plotregion1 , ring(1) 
.insert (b2title = .sized_textbox.new, mtextq(`""') style(scheme b1title) ) below plotregion1 , ring(2) 
.insert (note = .sized_textbox.new, mtextq(`""') style(scheme note) ) below plotregion1 , ring(4) 
.note.style.editstyle box_alignment(SW) editcopy
.note.style.editstyle horizontal(left) editcopy
.insert (caption = .sized_textbox.new, mtextq(`""') style(scheme caption) ) below plotregion1 , ring(5) 
.caption.style.editstyle box_alignment(SW) editcopy
.caption.style.editstyle horizontal(left) editcopy
.insert (subtitle = .sized_textbox.new, mtextq(`""') style(scheme subtitle) ) above plotregion1 , ring(6) 
.subtitle.style.editstyle box_alignment(N) editcopy
.subtitle.style.editstyle horizontal(center) editcopy
.insert (title = .sized_textbox.new, mtextq(`""Histogram""') style(scheme title) ) above plotregion1 , ring(7) 
.title.style.editstyle box_alignment(N) editcopy
.title.style.editstyle horizontal(center) editcopy
.insert (spacert = .spacer.new) above plotregion1 , ring(11)
.insert (spacerb = .spacer.new) below plotregion1 , ring(11)
.insert (spacerl = .spacer.new) leftof plotregion1 , ring(11)
.insert (spacerr = .spacer.new) rightof plotregion1 , ring(11)
.command = `"two  (hist u)                                                , title("Histogram")                    saving(Fig2a.b, replace)"'
.date = "10 Dec 2018"
.time = "14:28:25"
.dta_file = ""
.dta_date = ""
<EndItem>
