//
// $Id: $


package com.threerings.orth.server;

import com.threerings.orth.data.ClientMediaDesc;
import com.threerings.orth.data.URLMediaDesc;

/**
 * A simple implementation of MediaDescFactory that, so far, only knows how to create
 * {@link URLMediaDesc} objects.
 */
public class OrthMediaDescFactory extends MediaDescFactory
{
    @Override public ClientMediaDesc make (String URL, byte mimeType, byte constraint)
    {
        return new URLMediaDesc(URL, mimeType, constraint);
    }
}
