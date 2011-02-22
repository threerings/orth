//
// $Id$

package com.threerings.orth.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.orth.aether.data.PlayerName;

public class Speak extends SimpleStreamableObject
{
    public Speak ()
    {
    }

    public Speak (PlayerName from, String message)
    {
        _from = from;
        _message = message;
    }

    protected PlayerName _from;
    protected String _message;
}
