package com.threerings.orth.client
{
public class Resources
{
    [Embed(source="../../../../../../../rsrc/media/idle.swf")]
    public static const IDLE_ICON:Class;

    [Embed(source="../../../../../../../rsrc/media/walkable.swf")]
    public static const WALKTARGET:Class;

    [Embed(source="../../../../../../../rsrc/media/flyable.swf")]
    public static const FLYTARGET:Class;

    [Embed(source="../../../../../../../rsrc/media/skins/menu/avatar.png")]
    public static const AVATAR_ICON:Class;

    [Embed(source="../../../../../../../rsrc/media/skins/menu/bleep.png")]
    public static const BLEEP_ICON:Class;

    [Embed(source="../../../../../../../rsrc/media/loading.swf", mimeType="application/octet-stream")]
    public static const SPINNER:Class;
}
}
