import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import {
  ProgressBar,
  Section,
  Tabs,
  Button,
  Stack,
  Input,
  BlockQuote,
  Collapsible,
  LabeledList,
} from '../components';

export const NtosScipaper = (props, context) => {
  return (
    <NtosWindow width={600} height={500}>
      <NtosWindow.Content scrollable>
        <NtosScipaperContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosScipaperContent = (props, context) => {
  const { act, data } = useBackend(context);
  const NtosScipaperContentHeader = (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Scientific Renown">
          {data.renown_rank}
          <ProgressBar
            color="good"
            value={(data.scirenown % 100) / 100}></ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Scientific Cooperation">
          {data.coop_rank}
          <ProgressBar
            color="good"
            value={(data.scicoop % 100) / 100}></ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );

  const NtosScipaperPublishing = data.current_tab === 1 && (
    <Section>
      <Section title="Submission Form">
        <Stack fill>
          <LabeledList>
            <LabeledList.Item label="Title">
              <Input
                fluid
                value={data.title}
                onChange={(e, value) =>
                  act('rewrite', {
                    title: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Principal Author">
              <Input
                fluid
                value={data.author}
                onChange={(e, value) =>
                  act('rewrite', {
                    author: value,
                  })
                }
              />
              <Button
                selected={data.et_alia == true}
                onClick={() => act('et_alia')}>
                {'Multiple Authors'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Abstract">
              <Input
                fluid
                value={data.abstract}
                onChange={(e, value) =>
                  act('rewrite', {
                    abstract: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Stack>
      </Section>
      <Section title="Expected Yield">
        <Stack fill>
          <Stack.Item grow>
            {'Renown: '}
            <BlockQuote>{data.gains['renown']}</BlockQuote>
          </Stack.Item>
          <Stack.Item grow>
            {'Cooperation: '}
            <BlockQuote>{data.gains['cooperation']}</BlockQuote>
          </Stack.Item>
          <Stack.Item grow>
            {'Funding: '}
            <BlockQuote>{data.gains['funding']}</BlockQuote>
          </Stack.Item>
        </Stack>
      </Section>
      <Button onClick={() => act('publish')}>Publish Paper</Button>
    </Section>
  );
  const NtosScipaperReadprev = data.current_tab === 2 && (
    <Section>
      {data.published_papers.map((paper) => (
        <Collapsible title={paper['title']}>
          <LabeledList>
            <LabeledList.Item label="Author">
              {paper['author']}
            </LabeledList.Item>
            <LabeledList.Item label="Yield">
              <LabeledList>
                <LabeledList.Item label="Renown">
                  {paper['yield']['renown']}
                </LabeledList.Item>
                <LabeledList.Item label="Cooperation">
                  {paper['yield']['cooperation']}
                </LabeledList.Item>
                <LabeledList.Item label="Funding">
                  {paper['yield']['funding']}
                </LabeledList.Item>
              </LabeledList>
            </LabeledList.Item>
            <LabeledList.Item label="Abstract">
              {paper['abstract']}
            </LabeledList.Item>
          </LabeledList>
        </Collapsible>
      ))}
    </Section>
  );
  const NtosScipaperSciprogs = data.current_tab === 3 && (
    <Section>
      <Stack vertical></Stack>
    </Section>
  );

  return (
    <Section>
      {NtosScipaperContentHeader}
      <Section>
        <Tabs>
          <Tabs.Tab
            selected={data.current_tab === 1}
            onClick={() =>
              act('change_tab', {
                new_tab: 1,
              })
            }>
            {'Publishing Papers'}
          </Tabs.Tab>
          <Tabs.Tab
            selected={data.current_tab === 2}
            onClick={() =>
              act('change_tab', {
                new_tab: 2,
              })
            }>
            {'View Previous Publications'}
          </Tabs.Tab>
          <Tabs.Tab
            selected={data.current_tab === 3}
            onClick={() =>
              act('change_tab', {
                new_tab: 3,
              })
            }>
            {'View Scientific Programs'}
          </Tabs.Tab>
        </Tabs>
      </Section>
      {NtosScipaperPublishing}
      {NtosScipaperReadprev}
      {NtosScipaperSciprogs}
    </Section>
  );
};
