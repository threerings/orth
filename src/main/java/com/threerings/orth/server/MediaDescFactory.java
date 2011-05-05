//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.server;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.MediaMimeTypes;

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

    public MediaDesc make (String URL)
    {
        int ix = URL.lastIndexOf('.');
        if (ix < 0) {
            throw new IllegalArgumentException("Can't build MediaDesc from suffix-less URL.");
        }
        return make (URL.substring(0, ix), MediaMimeTypes.suffixToMimeType(URL));
    }

    public abstract MediaDesc make (String URL, byte mimeType);

    protected static MediaDescFactory _self;
}
