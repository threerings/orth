//
// $Id$

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
        // ORTH TODO: Should only pass in the path component of URL here
        return make (URL, MediaMimeTypes.suffixToMimeType(URL));
    }

    public MediaDesc make (String URL, byte mimeType)
    {
        return make (URL, mimeType, MediaDesc.NOT_CONSTRAINED);
    }

    public abstract MediaDesc make (String URL, byte mimeType, byte constraint);

    protected static MediaDescFactory _self;
}
