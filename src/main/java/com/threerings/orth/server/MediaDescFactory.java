//
// $Id$

package com.threerings.orth.server;

import com.threerings.orth.data.ClientMediaDesc;

import static com.threerings.orth.Log.log;

/**
 * A central class for statically constructor media descriptors that are ready to view
 * on a client, which for us means they need to be signed for Amazon's CloudFront service.
 */
public abstract class MediaDescFactory
{
    public static void init (MediaDescFactory factory)
    {
        _self = factory;
    }

    public static MediaDescFactory get ()
    {
        return _self;
    }

    public abstract ClientMediaDesc make (String URL, byte mimeType, byte constraint);

    protected static MediaDescFactory _self;
}
