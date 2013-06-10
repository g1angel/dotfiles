#!/bin/bash

MENU_XML="${HOME}/.config/openbox/menu.xml"
echo '<?xml version="1.0" encoding="UTF-8"?> 
<openbox_menu> 
	<menu id="root-menu" label="OpenBox 3"> 
        <separator label="Applications"/> ' > $MENU_XML
#echo "    $(mmaker -ci OpenBox3)" >> $HOME/.config/openbox/menu.xml
echo "    $(xdg_menu --format openbox3 --root-menu /etc/xdg/menus/lxde-applications.menu)" >> $MENU_XML
#echo '        <separator label="Settings"/> ' >> $MENU_XML
#echo "    $(xdg_menu --format openbox3 --root-menu /etc/xdg/menus/gnomecc.menu)" >> $MENU_XML
echo '		<separator label="OpenBox"/> 
    <menu id="client-list-menu"/> 
        <item label="Change Wallpaper">
            <action name="Execute">
                <execute>nitrogen</execute>
            </action>
        </item>
        <item label="Update Menu">
            <action name="Execute">
                <execute>sh '$HOME'/bin/ob_makemenu.sh</execute>
            </action>
        </item>
        <item label="Reconfigure"> <action name="Reconfigure"/> </item> 
        <separator/> 
        <item label="Exit"> <action name="Exit"/> </item> 
	</menu> 
</openbox_menu>' >> $MENU_XML
sed -i 's/pasuspender//g' $MENU_XML
sed -i 's_/usr/lib/firefox/firefox_'$HOME'/bin/multifox_g' $MENU_XML
openbox --reconfigure
