// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "src/ERC5643.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract BallsOfArt is ERC721, Ownable, ERC5643 {
    // Structs
    struct Ball {
        uint x; // x coordinates of the top left corner
        uint y; // y coordinates of the top left corner
        uint width;
        uint height;
        string fill; // ball color
        uint randomSeed;
    }

    // Constants, public variables
    uint constant maxSupply = 111; // max number of tokens
    uint public totalSupply = 0; // number of tokens minted
    uint public mintPrice = 0.0001 ether;

    // Mapping to store SVG code for each token
    mapping(uint => string) private tokenIdToSvg;

    // Events
    event BallsCreated(uint indexed tokenId);

    constructor() ERC721("Ballient", "BLNT") {}

    // Functions

    // Return a random background color
    function backgroundColors(uint index)
        internal
        pure
        returns (string memory)
    {
        string[33] memory bgColors = [
            "#1eafed",
            "#25316D",
            "#325fa3",
            "#367E18",
            "#38e27d",
            "#400D51",
            "#5d67c1",
            "#7294d4",
            "#A1C298",
            "#CC3636",
            "#F07DEA",
            "#F637EC",
            "#FA7070",
            "#a74f6c",
            "#c2c2d0",
            "#cc0e74",
            "#e5c37a",
            "#e6a0c4",
            "#e8185d",
            "#4bbe9d",
            "#fb97b3",
            "#ff0000",
            "#000007",
            "#2A0944",
            "#3330E4",
            "#5bbcd6",
            "#74275c",
            "#8758FF",
            "#96ac92",
            "#9c65ca",
            "#D800A6",
            "#F57328",
            "#FECD70"
        ];
        return bgColors[index];
    }

    // Return a random ball color
    function ballColors(uint index) internal pure returns (string memory) {
        string[33] memory bColors = [
            "#1eafed",
            "#25316D",
            "#325fa3",
            "#367E18",
            "#38e27d",
            "#400D51",
            "#5d67c1",
            "#7294d4",
            "#A1C298",
            "#CC3636",
            "#F07DEA",
            "#F637EC",
            "#FA7070",
            "#a74f6c",
            "#c2c2d0",
            "#cc0e74",
            "#e5c37a",
            "#e6a0c4",
            "#e8185d",
            "#4bbe9d",
            "#fb97b3",
            "#ff0000",
            "#000007",
            "#2A0944",
            "#3330E4",
            "#5bbcd6",
            "#74275c",
            "#8758FF",
            "#96ac92",
            "#9c65ca",
            "#D800A6",
            "#F57328",
            "#FECD70"
        ];
        return bColors[index];
    }

    
    // Create an instance of a Ball
    function createBallStruct(
        uint x,
        uint y,
        uint width,
        uint height,
        uint randomSeed
    ) internal pure returns (Ball memory) {
        return
            Ball({
                x: x,
                y: y,
                width: width,
                height: height,
                fill: ballColors(randomSeed % 33), // Choose random color from bColors array
                randomSeed: randomSeed
            });
    }

    // Randomly picka a ball size: 1, 2, or 3x
    function drawBallSize(uint maxSize, uint randomSeed)
        public
        pure
        returns (uint size)
    {
        // Random number 1-100
        uint r = (randomSeed % 100) + 1;
        
        if (maxSize == 3) {
            if (r <= 20) {
                return 1;
            } else if (r <= 45) {
                return 1;
            } else {
                return 1;
            }
        } else {
            // Probabilities:
            // 2x: 30%
            // else: 1x
            if (r <= 30) {
                return 1;
            } else {
                return 1;
            }
        }
    }

    // SVG code for a single ball
    function ballSvg(Ball memory ball) public pure returns (string memory) {
    return
        string(
            abi.encodePacked(
                '<defs>',
                '<radialGradient id="gradient" cx="50%" cy="50%" r="50%" fx="50%" fy="50%">',
                '<stop offset="0%" stop-color="',
                ball.fill,
                '"/>',
                '<stop offset="100%" stop-color="#FFFFFF"/>',
                '</radialGradient>',
                '<pattern id="pattern" x="0" y="0" width="10" height="10" patternUnits="userSpaceOnUse">',
                '<path d="M-1,1 l2,-2 M0,10 l10,-10 M9,11 l2,-2" stroke="',
                ball.fill,
                '" stroke-width="1" />',
                '</pattern>',
                '</defs>',
                '<circle cx="',
                uint2str(ball.x + ball.width/2),
                '" cy="',
                uint2str(ball.y + ball.height/2),
                '" r="',
                uint2str(ball.width/2),
                '" fill="url(#gradient)" />',
                '<circle cx="',
                uint2str(ball.x + ball.width/2),
                '" cy="',
                uint2str(ball.y + ball.height/2),
                '" r="',
                uint2str(ball.width/2),
                '" fill="url(#pattern)" />'
            )
        );
}


    // SVG code for a single line
    function generateLineSvg(uint lineNumber, uint randomSeed)
        public
        view
        returns (string memory)
    {
        // Line SVG
        string memory lineSvg = "";

        uint y = 475; // Default y for row 1
        if (lineNumber == 2) {
            y = 475; // Default y for row 2
        } else if (lineNumber == 3) {
            y = 475; // Default y for row 3
        }

        // Size of ball at slot 1
        uint ballSize1 = drawBallSize(3, randomSeed);
       

        // Ball size 1x? Paint 1x at slot 1
        if (ballSize1 == 1) {
            Ball memory ball1 = createBallStruct(150, y, 300, 300, randomSeed);
            lineSvg = string.concat(lineSvg, ballSvg(ball1));

            // Slot 2
            // Size of ball at slot 2
            uint ballSize2 = drawBallSize(2, randomSeed >> 1);
        

            // Ball size 1x? Paint 1x at slot 2 and 1x at slot 3
            if (ballSize2 == 1) {
                Ball memory ball2 = createBallStruct(
                    475,
                    y,
                    300,
                    300,
                    randomSeed >> 2
                );
                Ball memory ball3 = createBallStruct(
                    800,
                    y,
                    300,
                    300,
                    randomSeed >> 3
                );
                lineSvg = string.concat(
                    lineSvg,
                    ballSvg(ball2),
                    ballSvg(ball3)
                );

                // Ball size 2x? Paint 2x at slot 2
            } else if (ballSize2 == 2) {
                Ball memory ball2 = createBallStruct(
                    475,
                    y,
                    300,
                    625,
                    randomSeed >> 4
                );
                lineSvg = string.concat(lineSvg, ballSvg(ball2));
            }

            // Ball size 2x? Paint 2x at slot 1 and 1x at slot 3
        } else if (ballSize1 == 2) {
            Ball memory ball1 = createBallStruct(
                150,
                y,
                300,
                    625,
                randomSeed >> 5
            );
            Ball memory ball3 = createBallStruct(
                800,
                y,
                300,
                300,
                randomSeed >> 6
            );
            lineSvg = string.concat(lineSvg, ballSvg(ball1), ballSvg(ball3));

            // Ball size 3x? Paint 3x at slot 1
        } else if (ballSize1 == 3) {
            Ball memory ball1 = createBallStruct(
                150,
                y,
                300,
                    950,
                randomSeed >> 7
            );
            lineSvg = string.concat(lineSvg, ballSvg(ball1));
        }

        return lineSvg;
    }

   
    // Final SVG code for the NFT
    function generateFinalSvg(
        uint randomSeed1,
        uint randomSeed2,
        uint randomSeed3
    ) public view returns (string memory) {
        bytes memory backgroundCode = abi.encodePacked(
            '<rect width="1250" height="1250" fill="',
            backgroundColors(randomSeed1 % 7),
            '" />'
        );



        // SVG opening and closing tags, background color + 3 lines generated
        string memory finalSvg = string(
            abi.encodePacked(
                '<svg viewBox="0 0 1250 1250" xmlns="http://www.w3.org/2000/svg">',
                backgroundCode,
                generateLineSvg(1, randomSeed1),
                generateLineSvg(2, randomSeed2),
                generateLineSvg(3, randomSeed3),
            
                "</svg>"
            )
        );

      
        return finalSvg;
    }

    // Generate token URI with all the SVG code, to be stored on-chain
    function tokenURI(uint tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "Balls of Art #',
                                uint2str(tokenId),
                                '", "description": "Balls of Art are an assortment of 111 fully on-chain, randomly generated, happy art balls", "attributes": "", "image":"data:image/svg+xml;base64,',
                                Base64.encode(bytes(tokenIdToSvg[tokenId])),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    // Mint new Balls of Art
    function mintBallsOfArt(uint tokenId) public payable {
        // Require token ID to be between 1 and maxSupply (111)
        require(tokenId > 0 && tokenId <= maxSupply, "Token ID invalid");

        // Make sure the amount of ETH is equal or larger than the minimum mint price
        require(msg.value >= mintPrice, "Not enough ETH sent");

        uint randomSeed1 = uint(
            keccak256(abi.encodePacked(block.basefee, block.timestamp))
        );
        uint randomSeed2 = uint(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        );
        uint randomSeed3 = uint(
            keccak256(abi.encodePacked(msg.sender, block.timestamp))
        );

        tokenIdToSvg[tokenId] = generateFinalSvg(
            randomSeed1,
            randomSeed2,
            randomSeed3
        );

        // Mint token
        _mint(msg.sender, tokenId);

        // Increase minted tokens counter
        ++totalSupply;

        emit BallsCreated(tokenId);
    }

    // Withdraw funds from the contract
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // From: https://stackoverflow.com/a/65707309/11969592
    function uint2str(uint _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}