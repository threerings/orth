//
// $Id: $

package com.threerings.orth.entity.data;

import com.threerings.orth.data.MediaDesc;

public class MediaWalkability extends Walkability
{
    public MediaWalkability ()
    {
    }

    public MediaWalkability (MediaDesc media)
    {
        _media = media;
    }

    protected MediaDesc _media;
}
