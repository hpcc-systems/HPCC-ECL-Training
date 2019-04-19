inRec := RECORD
    UNSIGNED id;
    STRING name;
END;

outRec := RECORD
    UNSIGNED id;
    UNSIGNED len;
    STRING name;
END;

streamed dataset(outRec) transformDataset(streamed dataset(inRec) ds) := EMBED(C++ : activity)

#include <stdio.h>

#body

class MyStreamInlineDataset : public RtlCInterface, implements IRowStream
    {
    public:
        MyStreamInlineDataset(IEngineRowAllocator * _resultAllocator, IRowStream * _ds)
        : resultAllocator(_resultAllocator), ds(_ds)
        {
        }
        RTLIMPLEMENT_IINTERFACE
 
        virtual const void *nextRow() override
        {
            const byte * rowIn = (const byte *)ds->nextRow();
            if (!rowIn)
            {
                rowIn = (const byte *)ds->nextRow();
                if (!rowIn)
                    return NULL;
            }
            //read id
            byte *posIn = const_cast<byte*> (rowIn);
            unsigned __int64 id = *(__uint64 *)(posIn);
            //read length of name
            posIn += sizeof(__uint64);
            unsigned __int64 len = *(size32_t *)(posIn);
            //read name 
            posIn += sizeof(size32_t);
            char * name = (char *)(posIn);

            rtlReleaseRow(rowIn);

            RtlDynamicRowBuilder rowBuilder(resultAllocator);

            uint32_t returnSize = sizeof(unsigned __int64) * 2 + sizeof(size32_t) + len;
            const byte * rowOut = rowBuilder.ensureCapacity(returnSize, NULL);
            //write id 
            byte *posOut = const_cast<byte*> (rowOut);
            *(__uint64 *)(posOut) = id;
            //write length of name   
            posOut += sizeof(uint64_t);
            *(__uint64 *)(posOut) = len;           
            //write name but as uppercase 
            posOut += sizeof(uint64_t);
            *(size32_t *)posOut = len;
            posOut += sizeof(size32_t);
            //memcpy(posOut, (byte*)name, len);//use this if not uppercasing
            for (unsigned int x = 0; x < len; x++)
                posOut[x] = toupper(name[x]);

            return rowBuilder.finalizeRowClear(returnSize);
        }
        virtual void stop() override
        {
            ds->stop();
        }
 
 
    protected:
        Linked<IEngineRowAllocator> resultAllocator;
        IRowStream * ds;
    };
 
    return new MyStreamInlineDataset(_resultAllocator, ds);   
 

ENDEMBED;

ds := DATASET([{1, 'John Smith'}, {2, 'Dan Camper'}], inRec);
OUTPUT(transformDataset(ds));