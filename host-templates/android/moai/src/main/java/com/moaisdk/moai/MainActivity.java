package com.moaisdk.moai;



import android.os.Bundle;

import com.moaisdk.core.MoaiActivity;


public class MainActivity extends MoaiActivity {
    protected void onCreate ( Bundle savedInstanceState ) {
        //set the work directory for this project
        this.luaWorkDir = "bundle/assets";
        super.onCreate(savedInstanceState);
    }
}
