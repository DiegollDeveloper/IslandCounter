// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.Dart';
import 'package:flutter/services.dart';

class IslandCounter extends StatefulWidget {
  const IslandCounter({Key? key}) : super(key: key);

  @override
  _IslandCounterState createState() => _IslandCounterState();
}

class _IslandCounterState extends State<IslandCounter> {
  bool dataLoaded = false;
  late double screenWidth;
  late double screenHeight;

  final TextEditingController _matrixLengthController = TextEditingController();
  final FocusNode _matrixLengthFocus = FocusNode();

  int? generatedMatrixLength; //Length of generated matrix
  List<List<int>> generatedMatrix = [];
  List<List<int>> generatedAuxMatrix = [];
  List<List<List<int>?>> positionsMatrix = [];

  int islandsCounter1 = 0;
  int islandsCounter2 = 0;
  DateTime? initialTimeFirstWay;
  String firstWayTime = "";
  DateTime? initialTimeSecondWay;
  String secondWayTime = "";

  Function eq = const ListEquality().equals;

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewPadding.top;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _matrixLengthFocus.dispose();
    _matrixLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: screenHeight * 0.07,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Islands counter",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05),
            ),
            Container(
                margin: EdgeInsets.only(
                    top: screenHeight * 0.02,
                    left: screenWidth * 0.1,
                    right: screenWidth * 0.1,
                    bottom: screenHeight * 0.02),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Color(Colors.grey[300]!.value), blurRadius: 5)
                    ]),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        onSubmitted: (val) {
                          generateMatrix();
                          initialTimeFirstWay = DateTime.now();
                          getIslandsNumber();
                          firstWayTime = getFormatTime(initialTimeFirstWay!);

                          initialTimeSecondWay = DateTime.now();
                          calculatePositionsMatrix();
                          secondWayTime = getFormatTime(initialTimeSecondWay!);
                        },
                        controller: _matrixLengthController,
                        focusNode: _matrixLengthFocus,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            labelText: "Matrix length"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _matrixLengthFocus.unfocus();
                        generateMatrix();
                        initialTimeFirstWay = DateTime.now();
                        getIslandsNumber();
                        firstWayTime = getFormatTime(initialTimeFirstWay!);

                        initialTimeSecondWay = DateTime.now();
                        calculatePositionsMatrix();
                        secondWayTime = getFormatTime(initialTimeSecondWay!);
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.012),
                          decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text("Generate",
                              style: TextStyle(
                                  fontSize: screenWidth * 0.038,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    )
                  ],
                )),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // primary: true,
              child: Container(
                height: screenHeight * 0.6,
                width: screenWidth * 0.1 * generatedMatrix.length,
                margin: EdgeInsets.only(top: screenHeight * 0.02),
                child: ListView.builder(
                    primary: true,
                    shrinkWrap: true,
                    itemCount: generatedMatrix.length,
                    itemBuilder: (context, rowIndex) {
                      return SizedBox(
                        height: screenHeight * 0.05,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: generatedMatrix.length,
                            itemBuilder: (columContext, columnIndex) {
                              return GestureDetector(
                                onTap: () {
                                  changeFieldValue(rowIndex, columnIndex);
                                },
                                child: Container(
                                  width: screenWidth * 0.1,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: (generatedMatrix[rowIndex]
                                                [columnIndex] ==
                                            1)
                                        ? Colors.green[200]
                                        : Colors.lightBlue[100],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    generatedMatrix[rowIndex][columnIndex]
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.035),
                                  ),
                                ),
                              );
                            }),
                      );
                    }),
              ),
            ),
            (generatedMatrix.isNotEmpty)
                ? Container(
                    margin: EdgeInsets.only(
                        top: screenHeight * 0.03, bottom: screenHeight * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Recursive way
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: screenHeight * 0.02),
                              child: Text(
                                "Recursive Way:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.045),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Inslands: ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.035),
                                ),
                                Text(
                                  islandsCounter2.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.05),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Duration: ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.035),
                                ),
                                Text(
                                  firstWayTime.toString() + " ms",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.04),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Normal way
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: screenHeight * 0.02),
                              child: Text(
                                "Normal Way(O4):",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.045),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Inslands: ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.035),
                                ),
                                Text(
                                  islandsCounter2.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.05),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Duration: ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.035),
                                ),
                                Text(
                                  secondWayTime.toString() + " ms",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.04),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ))
                : const SizedBox()
          ],
        ),
      ),
    ));
  }

  void generatePositionsMatrix() {
    try {
      if (generatedMatrixLength != null) {
        positionsMatrix.clear();
        for (int i = 0; i < generatedMatrixLength!; i++) {
          positionsMatrix.add([]);
        }
      }
    } catch (e) {
      print("ERROR generateOneMatrix: $e");
    }
  }

  // Generate Square Matrix
  void generateMatrix() {
    try {
      if (_matrixLengthController.text.isNotEmpty) {
        generatedMatrixLength = int.parse(_matrixLengthController.text);
        generatedMatrix.clear();
        positionsMatrix.clear();
        for (int i = 0; i < generatedMatrixLength!; i++) {
          generatedMatrix.add([]);
          positionsMatrix.add([]);
          for (int j = 0; j < generatedMatrixLength!; j++) {
            int rand = Random().nextInt(2);
            generatedMatrix[i].add(rand);
          }
        }
        setState(() {});
        print(generatedMatrix);
      }
    } catch (e) {
      print("ERROR generateMatrix: $e");
    }
  }

  //Generate a matrix of list of positions when pivot is equal to 1
  void calculatePositionsMatrix() {
    try {
      generatePositionsMatrix();
      List<int> auxList = [];
      for (int rowIndex = 0; rowIndex < positionsMatrix.length; rowIndex++) {
        for (int columnIndex = 0;
            columnIndex < positionsMatrix.length;
            columnIndex++) {
          if (generatedMatrix[rowIndex][columnIndex] == 1) {
            auxList.add(columnIndex);
            if (columnIndex == positionsMatrix.length - 1) {
              positionsMatrix[rowIndex].add(List.of(auxList));
              auxList.clear();
            }
          } else {
            if (auxList.isNotEmpty) {
              positionsMatrix[rowIndex].add(List.of(auxList));
              auxList.clear();
            }
          }
        }
      }
      print(positionsMatrix);
      calculateIslandsNumber();
    } catch (e) {
      print("ERROR calculateIslandsNumber: $e");
    }
  }

  // Get the number of islands
  void calculateIslandsNumber() {
    try {
      List<Map<String, dynamic>> currentListElements = [];
      List<Map<String, dynamic>> nextListElements = [];
      List<Map<String, dynamic>> auxCurrentListElements = [];
      Map<String, dynamic> auxList = {"list": [], "added": false};
      Map<String, dynamic> newMapList = {"list": [], "added": true};
      List newList = [];
      List<int> indexToConcat = [];
      bool concat;
      int counter = 0;
      islandsCounter2 = 0;

      // Go across row Ones matrix
      for (int rowIndex = 0; rowIndex < positionsMatrix.length; rowIndex++) {
        if (rowIndex == 0 && positionsMatrix[rowIndex].isNotEmpty) {
          // Get list of maps from current row
          for (List<int>? rowMap in positionsMatrix[rowIndex]) {
            currentListElements.add({"list": List.of(rowMap!), "added": false});
          }
        }
        if (rowIndex != positionsMatrix.length - 1) {
          // Get list of maps from next row
          for (var rowList in positionsMatrix[rowIndex + 1]) {
            nextListElements.add({"list": List.of(rowList!), "added": false});
          }
          // Go across current one matrix row element
          for (Map<String, dynamic> elementsList in currentListElements) {
            bool contains = false;
            // Go across next one matrix row
            for (int nexRowIndex = 0;
                nexRowIndex < nextListElements.length;
                nexRowIndex++) {
              // Go across next row elements
              for (int i = 0;
                  i < nextListElements[nexRowIndex]["list"].length;
                  i++) {
                var element = nextListElements[nexRowIndex]["list"][i];
                if (elementsList["list"].contains(element)) {
                  auxList["list"]
                      .addAll(List.of(nextListElements[nexRowIndex]["list"]));
                  auxList["added"] = true;
                  nextListElements[nexRowIndex]["added"] = true;
                  contains = true;
                  break;
                }
              }
            }
            if (!contains) {
              islandsCounter2++;
            }
            if (auxList["list"].isNotEmpty) {
              auxCurrentListElements.add(Map.of(auxList));
              auxList = {"list": [], "added": false};
            }
          }
          for (var element in nextListElements) {
            if (!element["added"]) {
              element["added"] = true;
              auxCurrentListElements.add(Map.of(element));
            }
          }

          newMapList = {"list": [], "added": true};
          newList = [];
          indexToConcat = [];
          counter = 0;

          // Verify is a group of elements belong to the same island
          do {
            concat = false;
            for (int i = 0; i < auxCurrentListElements.length; i++) {
              for (int j = i + 1;
                  j != i && j < auxCurrentListElements.length;
                  j++) {
                if (i < auxCurrentListElements.length - 1) {
                  List list1 = auxCurrentListElements[i]["list"];
                  List list2 = auxCurrentListElements[j]["list"];

                  for (int element in list2) {
                    if (list1.contains(element)) {
                      indexToConcat.add(i);
                      indexToConcat.add(j);
                      concat = true;
                      break;
                    }
                  }
                }
                if (concat) {
                  break;
                }
              }
              if (concat) {
                break;
              }
            }

            if (concat) {
              newList = auxCurrentListElements[indexToConcat[0]]["list"] +
                  auxCurrentListElements[indexToConcat[1]]["list"];
              newMapList["list"] = List.of(newList.toSet().toList());
              indexToConcat.sort((a, b) => b.compareTo(a));
              auxCurrentListElements.removeAt(indexToConcat[0]);
              auxCurrentListElements.removeAt(indexToConcat[1]);
              auxCurrentListElements.add(Map.of(newMapList));
              newList.clear();
              newMapList = {"list": [], "added": true};
              indexToConcat.clear();
            }
            counter++;
          } while (concat && counter < 100);
          if (counter == 100) {
            print(counter);
          }
          currentListElements = List.of(auxCurrentListElements);
          auxCurrentListElements.clear();
          nextListElements.clear();
        } else {
          // ignore: unused_local_variable
          for (Map<String, dynamic> elementsList in currentListElements) {
            islandsCounter2++;
          }
        }
      }
      setState(() {});
    } catch (e) {
      print("ERROR calculateIslandsNumber: $e");
    }
  }

  // Change tapped field value and verify his elements around
  changeFieldValue(int rowIndex, int colIndex) {
    try {
      // bool aboveIsland = false;
      // bool rightIsland = false;
      // bool belowIsland = false;
      // bool leftIsland = false;
      int islandsTogeter = 0;

      // Verify field above
      if ((rowIndex - 1 >= 0) && generatedMatrix[rowIndex - 1][colIndex] == 1) {
        // aboveIsland = true;
        islandsTogeter++;
      }
      // Verify field at right
      if ((colIndex + 1 < generatedMatrix.length) &&
          generatedMatrix[rowIndex][colIndex + 1] == 1) {
        // rightIsland = true;
        islandsTogeter++;
      }
      // Verify field below
      if ((rowIndex + 1 < generatedMatrix.length) &&
          generatedMatrix[rowIndex + 1][colIndex] == 1) {
        // belowIsland = true;
        islandsTogeter++;
      }
      // Verify field at left
      if ((colIndex - 1 >= 0) && generatedMatrix[rowIndex][colIndex - 1] == 1) {
        // leftIsland = true;
        islandsTogeter++;
      }

      if (generatedMatrix[rowIndex][colIndex] == 1) {
        // If field change to 0
        if (islandsTogeter == 0) {
          setState(() {
            islandsCounter1--;
            islandsCounter2--;
            generatedMatrix[rowIndex][colIndex] = 0;
          });
        } else if (islandsTogeter == 1) {
          setState(() {
            generatedMatrix[rowIndex][colIndex] = 0;
          });
        } else {
          setState(() {
            generatedMatrix[rowIndex][colIndex] = 0;
          });
          initialTimeFirstWay = DateTime.now();
          getIslandsNumber();
          firstWayTime = getFormatTime(initialTimeFirstWay!);

          initialTimeSecondWay = DateTime.now();
          calculatePositionsMatrix();
          secondWayTime = getFormatTime(initialTimeSecondWay!);
        }
      } else {
        // If field change to 1
        if (islandsTogeter == 0) {
          setState(() {
            islandsCounter1++;
            islandsCounter2++;
            generatedMatrix[rowIndex][colIndex] = 1;
          });
        } else if (islandsTogeter == 1) {
          setState(() {
            generatedMatrix[rowIndex][colIndex] = 1;
          });
        } else {
          setState(() {
            generatedMatrix[rowIndex][colIndex] = 1;
          });
          initialTimeFirstWay = DateTime.now();
          getIslandsNumber();
          firstWayTime = getFormatTime(initialTimeFirstWay!);

          initialTimeSecondWay = DateTime.now();
          calculatePositionsMatrix();
          secondWayTime = getFormatTime(initialTimeSecondWay!);
        }
      }
    } catch (e) {
      print("ERROR changeFieldValue: $e");
    }
  }

  //--------- Recursive Way ---------

  // Generate an auxiliar matrix from the generated matrix
  void generateAuxMatrix() {
    generatedAuxMatrix.clear();
    for (int i = 0; i < generatedMatrixLength!; i++) {
      generatedAuxMatrix.add([]);
      for (int j = 0; j < generatedMatrixLength!; j++) {
        generatedAuxMatrix[i].add(generatedMatrix[i][j]);
      }
    }
    print(generatedAuxMatrix);
  }

  // Verify values around the current
  void verifyNext(int i, int j) {
    if (i < 0 ||
        i >= generatedAuxMatrix.length ||
        j < 0 ||
        j >= generatedAuxMatrix.length ||
        generatedAuxMatrix[i][j] != 1) {
      return;
    }
    generatedAuxMatrix[i][j] = 0;
    verifyNext(i + 1, j);
    verifyNext(i - 1, j);
    verifyNext(i, j + 1);
    verifyNext(
      i,
      j - 1,
    );
  }

  // Calculate numbers of islands with a recursive function
  void getIslandsNumber() {
    generateAuxMatrix();
    islandsCounter1 = 0;
    for (int i = 0; i < generatedAuxMatrix.length; i++) {
      for (int j = 0; j < generatedAuxMatrix.length; j++) {
        if (generatedAuxMatrix[i][j] == 1) {
          islandsCounter1++;
          verifyNext(i, j);
        }
      }
    }
    print(generatedMatrix);
  }

  String getFormatTime(DateTime initialTime) {
    try {
      int time = DateTime.now().difference(initialTime).inMilliseconds;
      return time.toString();
    } catch (e) {
      print("ERROR getFormatTime: $e");
      return "";
    }
  }
}
