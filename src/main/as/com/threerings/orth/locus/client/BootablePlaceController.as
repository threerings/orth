//
// $Id: BootablePlaceController.as 9285 2008-05-28 01:56:04Z ray $

package com.threerings.orth.locus.client {

public interface BootablePlaceController
{
    /**
     * Can the local user boot people from this place?
     */
    function canBoot () :Boolean;
}
}
