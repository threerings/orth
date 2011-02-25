package com.threerings.orth.data;
// $Id: $

/**
 * An interface to be implemented by any MediaDesc that is ready to be actually rendered
 * in a browser; it points to a valid and resolvable resource. The main purpose of this
 * distinction is when we use Cloudfront URLs, where a vital signing process must happen
 * on the server to turn a hydrated description into one that the web server will accept.
 */
public interface ClientMediaDesc extends MediaDesc
{
    /**
     * Returns the path of the URL that references this media.
     */
    String getMediaPath ();
}
