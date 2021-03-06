--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}






function LevelMaker.generate(level_width, level_height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local keyGenerated = false
    local lockGenerated = false

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, level_height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, level_width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, level_height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, level_height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            lock = false,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        lock = false,
                        collidable = false
                    }
                )
            end


            -- chance to generate a key one time 
            if x > 4 and lockGenerated == false and math.random(15) == 7 then

                    lock = GameObject {
                    texture = 'keys-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = math.random(5,8),
                    collidable = true,
                    consumable = false,
                    solid = true,
                    hit = false,
                    lock = true,

                    onCollide = function(player, object)
                        if player.hasKey then 
                            gSounds['pickup']:play()
                            print("player collided with lock -- has key")
                            -- note the key is removed in JumpState when the collision happens, see there for info
                            
                            
                            -- todo I think sometimes the lock / key may spawn underneath a different block?
                            -- quick fix would be don't spawn any blocks in first x and spawn lock there, similar with key

                          
                            flagpole = { }

                            -- this is the flag itself
                            flagpole[1] = GameObject {
                                texture = 'flag-and-poles',
                                x = (level_width*TILE_SIZE) - (1.5*TILE_SIZE), -- shifted from the rest of the flagpole
                                y = TILE_SIZE + 8,                        
                                width = 16,
                                height = 8,
                                frame = 7,
                                collidable = true,
                                consumable = true,
                                solid = false,
                                hit = false,
                                lock = false,
                                
                               

                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    gSounds['powerup-reveal']:play()
                                    --player.score = player.score + 500

                                    player.x = player.x - PLAYER_WALK_SPEED
                                    player:changeState('falling')


                                    gStateMachine:change('play', {
                                        width = level_width + 20 ,
                                        score = player.score
                                    })
                                end
                            
                            
                            }

                            flagpole[2] = GameObject {
                                texture = 'flag-and-poles',
                                x = (level_width*TILE_SIZE) - (2 * TILE_SIZE),
                                y = TILE_SIZE,                        
                                width = 16,
                                height = 16,
                                frame = 3,
                                collidable = true,
                                consumable = true,
                                solid = false,
                                hit = false,
                                lock = false,

                                
                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    gSounds['powerup-reveal']:play()
                                    --player.score = player.score + 500

                                    player.x = player.x - PLAYER_WALK_SPEED
                                    player:changeState('falling')


                                    gStateMachine:change('play', {
                                        width = level_width + 20 ,
                                        score = player.score
                                    })
                                end
                                
                              
                            }

                            table.insert(objects, flagpole[1])
                            table.insert(objects, flagpole[2])
                            
                            -- the main part of the pole
                            for pole = 2, 4 do 
                            
                                flagpole[pole + 1] = GameObject {
                                    texture = 'flag-and-poles',
                                    x = (level_width*TILE_SIZE) - (2 * TILE_SIZE),
                                    y = pole * TILE_SIZE,
                                    width = 16,
                                    height = 16,
                                    frame = 12,
                                    collidable = true,
                                    consumable = true,
                                    solid = false,
                                    hit = false,
                                    lock = false,

                                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        gSounds['powerup-reveal']:play()
                                        --player.score = player.score + 500
    
                                        player.x = player.x - PLAYER_WALK_SPEED
                                        player:changeState('falling')
    
    
                                        gStateMachine:change('play', {
                                            width = level_width + 20 ,
                                            score = player.score
                                        })
                                    end

                                
                                    
                                }
                                print("loop", pole)
                                print("pole x,y: ", x, y)
                                print("level width: ", level_width)
                                print("player x,y: ", player.x, player.y)
                                table.insert(objects, flagpole[pole + 1])
                            end

                            -- the base
                            flagpole[7] = GameObject {
                                texture = 'flag-and-poles',
                                x = (level_width*TILE_SIZE) - (2 * TILE_SIZE),
                                y = TILE_SIZE * 5,                        
                                width = 16,
                                height = 16,
                                frame = 21, -- yellow base
                                collidable = true,
                                consumable = true,
                                solid = false,
                                hit = false,
                                lock = false,
                                
                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    gSounds['powerup-reveal']:play()
                                    --player.score = player.score + 500

                                    player.x = player.x - PLAYER_WALK_SPEED
                                    player:changeState('falling')


                                    gStateMachine:change('play', {
                                        width = level_width + 20 ,
                                        score = player.score
                                    })
                                end
                            
                            }
                            print ("pole2: ", pole2)
                            table.insert(objects, flagpole[7])


                            -- debug
                            print_r(flagpole)
                            -- print_r(objects)

                        else 
                            gSounds['empty-block']:play()
                            print("player collided with lock -- no key")
                        end
                    end
                }
            print("lock added")
            table.insert(objects, lock)
            
            -- debug
            --print_r ( lock )
            lockGenerated = true
            end

               

            -- chance to generate a lock one time 
            if x > 4 and keyGenerated == false and math.random(15) == 7 then 
            
                    key = GameObject {
                    texture = 'keys-locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = math.random(4),
                    collidable = true,
                    consumable = true,
                    solid = false,
                    hit = false,
                    lock = false,

                    onConsume = function(player, object)
                        gSounds['pickup']:play()
                        player.hasKey = true
                        print("player has key")
                    end
                }

            table.insert(objects, key)
            print("key added")
            
            -- debug
            --print_r ( key )
            keyGenerated = true
            end



            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,
                        lock = false,

                        -- collision function takes itself
                        onCollide = function(player, object)

                            -- spawn a gem if we haven't already hit the block
                            if not object.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,
                                        lock = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                object.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    -- here we make a small normal space for the flagpole to go later
    x = (level_width*TILE_SIZE) - (2 * TILE_SIZE)
        
    for y = 7, level_height do
        table.insert(tiles[y],
            Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
    end
    

    local map = TileMap(level_width, level_height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end