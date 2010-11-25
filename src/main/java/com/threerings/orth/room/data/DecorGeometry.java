package com.threerings.orth.room.data;

public interface DecorGeometry
{
    void setType (byte type);

    float getHorizon ();

    short getDepth ();

    short getWidth ();

    short getHeight ();

    float getActorScale ();

    float getFurniScale ();

    byte getDecorType ();
}
