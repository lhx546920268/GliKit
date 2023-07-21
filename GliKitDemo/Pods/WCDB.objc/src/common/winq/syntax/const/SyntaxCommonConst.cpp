//
// Created by sanhuazhang on 2019/05/02
//

/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "SyntaxCommonConst.hpp"
#include "StringView.hpp"

namespace WCDB {

namespace Syntax {

bool isIntegerColumnType(const UnsafeStringView& type)
{
    return type.caseInsensitiveEqual("INTEGER") || type.caseInsensitiveEqual("INT")
           || type.caseInsensitiveEqual("TINYINT") || type.caseInsensitiveEqual("SMALLINT")
           || type.caseInsensitiveEqual("MEDIUMINT") || type.caseInsensitiveEqual("BIGINT")
           || type.caseInsensitiveEqual("UNSIGNED BIG INT")
           || type.caseInsensitiveEqual("INT2") || type.caseInsensitiveEqual("INT8");
}

const char* masterTableString = "sqlite_master";
const char* sequenceTableString = "sqlite_sequence";
const char* mainSchemaString = "main";
const char* tempSchemaString = "temp";
const char* builtinTablePrefixString = "sqlite_";

const StringView* masterTablePtr
= new StringView(StringView::makeConstant(masterTableString));
const StringView* sequenceTablePtr
= new StringView(StringView::makeConstant(sequenceTableString));
const StringView* mainSchemaPtr
= new StringView(StringView::makeConstant(mainSchemaString));
const StringView* tempSchemaPtr
= new StringView(StringView::makeConstant(tempSchemaString));
const StringView* builtinTablePrefixPtr
= new StringView(StringView::makeConstant(builtinTablePrefixString));

const StringView& masterTable = *masterTablePtr;
const StringView& sequenceTable = *sequenceTablePtr;
const StringView& mainSchema = *mainSchemaPtr;
const StringView& tempSchema = *tempSchemaPtr;
const StringView& builtinTablePrefix = *builtinTablePrefixPtr;

} // namespace Syntax

} // namespace WCDB
