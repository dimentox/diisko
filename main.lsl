// Start core stats
integer health = 1000;
integer maxHealth = 1000;
integer inCombat = 0;
integer attack = 500;
integer defence = 500;
integer healTick = 20;
vector color = <1, 1, 1>;
string hover = "TOX v0.0.5\n";
key http;
integer dead = 0;
integer pendingDead = 0;  
string combatStyle;
integer handle;
integer combatHandle;

integer kd = 0;
integer boot = 1;

integer channel = -123223;
key target;
string gender; 
list genders = ["Male", "Female", "Mechanical"];
list hitSounds = [];
list maleHitSounds = ["9d61f965-fdcb-ae47-12ee-89102cb41cdc", "0ec5fc99-f358-3712-4f54-f4e2289ac411", "43ef713f-7347-7f5b-a670-78e7bd5ecbbe"];
list femaleHitSounds = ["eb925db5-80db-1927-ef2d-c589ada3933d", "324e96ef-8cc4-e6ea-3406-70edc890a733", "ce22a17a-3b4e-81a2-49f2-a3439de1e266"];
list mechHitSounds = ["c6788902-a3c3-b09f-9c91-07f2c8947cd9", "d71d1630-c99f-c86e-eb5e-c43b0c9cd79c", "64ebdb27-012f-e65f-ebc3-d8caac7e69d3",
                      "cae06e13-731f-e063-87db-5374bc1cb7da"];

float lastDamage = 100;
integer sen = 0;
string gPass = "somedsadsw232sds";
string action = "";
integer sendReady = 1;
float range = 4.0;
integer ranged = 1;
integer cloneHandle;

integer c_damage_count = 0;


integer frozen =0; 
freeze()
{
  
   
    llTakeControls(1, 1, 0); // glitch the rotation
    llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_ROT_LEFT | CONTROL_RIGHT| CONTROL_ROT_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON,1, 0);
  //llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON,1, 1);
 //llTakeControls( CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT| CONTROL_LBUTTON | CONTROL_ML_LBUTTON,1, 0);
    frozen = 1;
    
}


unfreeze()
{

    llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_ROT_LEFT | CONTROL_RIGHT| CONTROL_ROT_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON, 1, 1);
    frozen = 0;
   
}

string crypt(string str)
{
    return llXorBase64StringsCorrect(llStringToBase64(str), llStringToBase64(gPass));
}


string decrypt(string str)
{
    return llBase64ToString(llXorBase64StringsCorrect(str, llStringToBase64(gPass)));
}

string gen_random_from_list(list l)
{
    integer count = llFloor(llFrand(llGetListLength(l)));
    string found = llList2String(l, count);

    return found;
}
updateHover()
{
    if(inCombat)
    {
        color = <1, 0, 0>;
    }
    else
    {
        color = <1, 1, 1>;
    }
        
    llSetText(hover + "⦕ " + (string)health + " HEALTH ⦖", color, 1.0);
    
}


default
{
    state_entry()
    {
         llSetText(hover + "⦕ LOADING ⦖", color, 1.0);
        llOwnerSay("This system is a work in progress and is in alpha. Settings for gender and style of fighitng are not saved to DB yet.");
        llOwnerSay("Loading....");
       
        llMessageLinked(LINK_SET, 0, "partsoff", NULL_KEY);
        llRequestExperiencePermissions(llGetOwner(), "");
    }

    experience_permissions(key target_id)
    {
       // llOwnerSay("GOT PERMS");

        integer desired_controls = CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_LEFT |
                                   CONTROL_ROT_RIGHT |
        //CONTROL_UP |
        CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON;


        llTakeControls(desired_controls, TRUE, TRUE);

        state chooseSex;
       // state state_dead;
    }

    experience_permissions_denied(key agent_id, integer reason)
    {
        // Permissions denied, so go away
        llSay(0, "Denied experience permissions for " + (string)agent_id + " due to reason #" + (string)reason + "\nPlease ensure you allow the expierience the system requires it.");
    }
        on_rez(integer start_param)
    {
        llResetScript();
    }
}


state chooseSex
{
    state_entry()
    {
        handle = llListen(-42, "", llGetOwner(), "");
        llDialog(llGetOwner(), "Please choose your gender", ["Male", "Female", "Mechanical"], -42);
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    listen(integer channel, string name, key id, string message)
    {
        gender = message;

        if(gender == "Male")
        {
            hitSounds = maleHitSounds;
        }
        else if(gender == "Female")
        {
            hitSounds = femaleHitSounds;
        }
        else
        {
            hitSounds = mechHitSounds;
        }

        state chooseStyle;
    }

    state_exit()
    {
        llListenRemove(handle);
    }
}


state chooseStyle
{
    state_entry()
    {
        handle = llListen(-42, "", llGetOwner(), "");
        llDialog(llGetOwner(), "Please choose your fighting style.", ["Normal", "Aggressive", "Defensive"], -42);
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    listen(integer channel, string name, key id, string message)
    {
        combatStyle = message;

        if(combatStyle == "Aggressive")
        {
            attack = 1000;
            defence = 0;
        }
        else if(combatStyle == "Defensive")
        {
            defence = 1000;
            attack = 0;
        }
        else
        {

        }

        state running;
    }

    state_exit()
    {
        llListenRemove(handle);
    }
}


state running
{
    state_entry()
    {
        dead = 0;
        llOwnerSay("System running!");
        llListen(channel, "", "", "");
        llSetTimerEvent(.5);

    }
    on_rez(integer start_param)
    {
        llResetScript();
    }
    timer()
    {
      
        sendReady = 1;
        ranged = 1;
       
       if(c_damage_count >= 2)
       {
           c_damage_count = 0;
       } else {
            c_damage_count++;   
        }
       if(kd == 1)
       {
           freeze();
           llStartAnimation("knockdown");
           kd++;
                       
        }else if(kd == 4)
        {
             unfreeze();
            llStopAnimation("knockdown");
            kd = 0;
        }else if(kd >= 2)
        {
            kd++;
        } 
       

        float time = llGetTime();

        if(boot == 1 || inCombat && time > 30)
        {
            inCombat = 0;
            boot = 0;
           // llOwnerSay("Not in combat now");
        }
        if(!inCombat && time < 30)
        {
            inCombat=1;
        }

        if(!inCombat && health < maxHealth)
        {
            health = health + healTick;
        }

        if(health > maxHealth)
        {
            health = maxHealth;
        }
             updateHover();
        if(health <= 0 )
        {
            dead = 1;
            health = 0;
            state state_dead;
            return;
        }
        
    
       
    }

    listen(integer channel, string name, key id, string message)
    {

        string bbb = decrypt(message);
        list blahh = llParseString2List(bbb, ["|"], []);
        //llOwnerSay(bbb);
        if(llList2String(blahh, 0) == "damage" && llList2String(blahh, 1) ==
            llGetOwner())
        {
           // llOwnerSay("meh");
            integer damage = (integer)llList2String(blahh, 2);

            if(defence > 100)
            {
                if(damage != 0)
                {
                    damage = damage / 2;
                }
            }
            if(llGetListLength(blahh) > 3)
            {
                string animation = llList2String(blahh, 3);
                if(animation != "" && animation != "NONE")
                {
                    
                    llStartAnimation(animation);
                    if(animation == "knockdown")
                    {
                        freeze();
                        llSleep(2);
                        unfreeze();
                    }
                }
            }
            if(llGetListLength(blahh) > 4)
            {
                string sound = llList2String(blahh, 4);
                if(sound != "" && sound != "NONE")
                {
                    llTriggerSound(sound, 1.0);
                }
            }
            health = health - damage;
            llTriggerSound(gen_random_from_list(hitSounds), 1.0);
            llStartAnimation("hit");
            lastDamage = llGetAndResetTime();
        }
    }

    attach(key id)
    {
        if(id == NULL_KEY)
        {
            // if the object ever un-attaches, make sure it deletes itself
           // llOwnerSay("No longer attached");
            llResetScript();
        }
    }

    control(key id, integer held, integer change)
    {

        if(held & ~change & (CONTROL_LBUTTON) || held & ~change & (CONTROL_ML_LBUTTON))
        {
            if(held & change & (CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT))
            {
                if(sendReady)
                {
                   // llOwnerSay("Sensor");
                     llSensor("", NULL_KEY, AGENT, 3, PI / 4);
                }
            }
        }
    }

    no_sensor()
    {
        sen = 0;
    }

    sensor(integer num)
    {
        integer randomnumber = llFloor(llFrand(100.0));
        integer mdamage = randomnumber;
        integer i;

        if(attack > 100)
        {
            mdamage = mdamage + (mdamage / 2);
        }

        for(i = 0; i < num; i++)
        {

            integer vBitType = llDetectedType(i);

            if(vBitType & AGENT_BY_LEGACY_NAME)
            {

                action = "damage|" + (string)llDetectedKey(i) + "|" + (string)mdamage;
               // llOwnerSay(action);
                llShout(channel, crypt(action));
                sendReady = 0;

            }

        }

    }

    collision_start(integer times)
    {
       
        integer x;
        float tol = 17.0;
        vector v = llDetectedVel(0);

        integer flags = llDetectedType(0);
         integer randomnumber = llFloor(llFrand(100.0));
        integer damage = randomnumber;

        if(ACTIVE & flags)
        {
            
            if(llVecMag(v) > tol)
            {
               // llOwnerSay("Boom");
                if(!ranged)
                {
                    return;
                }
                if (c_damage_count > 0)
                {
                    c_damage_count++;
                    return;
                }
                 c_damage_count++;
                if(defence > 100)
                {
                    if(damage != 0)
                    {
                        damage = llFloor(damage / 2);
                    }
                }
                if(defence != 1000)
                {
                    if(randomnumber >=85)
                    {
                        lastDamage = llGetAndResetTime();
                        damage = damage + 25;
                       
                        health = health - damage;
                        damage = 0;
                        kd = 1;
                       

                        lastDamage = llGetAndResetTime();
                    }
                }
                    

                health = health - damage;
                llTriggerSound(gen_random_from_list(hitSounds), 1.0);
                llStartAnimation("hit");
                lastDamage = llGetAndResetTime();

            }
        }
    }
}


state state_dead
{
    state_entry()
    {
         llSetTimerEvent(60);
        
        llSetText(hover + "☠  DEAD ☠", <0,0,0>, 1.0);
        llStartAnimation("dead");
       
        integer c = ( 0x80000000 | (integer)("0x"+(string)llGetOwner()));
        cloneHandle = llListen(c, "", "", "");
         llRezObject("Blackout", llGetPos() + <0.0,0.0,1.0>, <0.0,0.0,0.0>, <0.0,0.0,0.0,1.0>, c);
         llSleep(9);
        llRezObject("Clone warp", llGetPos() + <0.0,0.0,1.0>, <0.0,0.0,0.0>, <0.0,0.0,0.0,1.0>, c);
        
        
        
      
    }
    on_rez(integer start_param)
    {
        llResetScript();
    }
    timer()
    {
       
                llSetTimerEvent(0);
                 health = 1;
                dead = 0;
                llStopAnimation("dead");
                state running;
       
    }
    listen(integer channel, string name, key id, string message)
    {
        if(llGetOwnerKey(id) == llGetOwner())
        {
            if(message == "clone")
            {
              
                health = 1;
                dead = 0;
                llStopAnimation("dead");
                state running;
            }
        }
    }
   
}
/*
 shoot()
 {
 vector start = llGetCameraPos();
 // Detect only a non-physical, non-phantom object. Report its root prim's UUID.
 list results = llCastRay(start, start+<60.0,0.0,0.0>*llGetCameraRot(),[RC_REJECT_TYPES,0,RC_DETECT_PHANTOM,TRUE,RC_DATA_FLAGS,RC_GET_ROOT_KEY,RC_MAX_HITS,1]);
 
 target = llList2Key(results,0);
 if (target == llGetOwner())
 {
 target = NULL_KEY;
 }
 integer is_agent = 0;
 if( llGetUsername(target) != "")
 {
 }
 }
 */