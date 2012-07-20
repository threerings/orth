//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.comms.data {

public interface RequestComm
{
    /** Called on the if the request is accepted. It should enact the acceptance. */
    function onAccepted () :void;

    /** Message to be displayed when the request is accepted. */
    function get acceptMessage () :String;

    /** Message to show to the when the request is presented. */
    function get toMessage () :String;

    /** Message to show if the request is ignored. */
    function get ignoreMessage () :String;
}
}
