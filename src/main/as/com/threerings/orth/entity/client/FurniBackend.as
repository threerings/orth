//
// $Id: FurniBackend.as 18542 2009-10-29 22:29:47Z ray $

package com.threerings.orth.entity.client {

import com.threerings.orth.client.OrthController;

public class FurniBackend extends EntityBackend
{
    override protected function populateControlProperties (o :Object) :void
    {
        super.populateControlProperties(o);

        o["showPage_v1"] = showPage_v1;
    }

    protected function showPage_v1 (token :String) :Boolean
    {
        // handleViewUrl will do the "right thing"
        _orthCtrl.handleViewUrl(DeploymentConfig.serverURL + "#" + token);
        return true;
    }

    [Inject] public var _orthCtrl :OrthController;
}
}
