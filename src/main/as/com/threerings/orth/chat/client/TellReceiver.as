//
// $Id$

package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationReceiver;

import com.threerings.orth.chat.data.Tell;

public interface TellReceiver extends InvocationReceiver
{
    // from Java interface TellReceiver
    function receiveTell (arg1 :Tell) :void;
}
}
